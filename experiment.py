import argparse
import os, sys
import time
import traceback
from datetime import datetime

import dropbox
from dropbox.exceptions import ApiError
from dropbox import files as dropf

"""
Script running a series of MPE RL experiments, optionally uploading results to Dropbox
"""

parser = argparse.ArgumentParser(description='Experiments runner.')
parser.add_argument("--local-dir",
                    type=str,
                    default="./results",
                    help="path to save checkpoints")
parser.add_argument("-r", "--repeat",
                    type=int,
                    default=7,
                    help="number of repetitions per experiment")
parser.add_argument("--dbox-token",
                    type=str,
                    default=None,
                    required=False,  # https://www.dropbox.com/developers/documentation/python
                    help="App token for Dropbox where results should be uploaded")
parser.add_argument("--dbox-dir",
                    type=str,
                    default='/experiment',
                    required=False,
                    help="Dropbox folder where results should be uploaded")
parser.add_argument('--use_gpu',
                    action='store_true')

args = parser.parse_args()

scenarios = [
    "simple_speaker_listener",
    "simple_spread",
    "simple_push",
    "simple_tag",
    "simple_crypto",
    "simple_adversary"
    "multi_speaker_listener",  # custom for MAAC
    "fullobs_collect_treasure",  # custom for MAAC
]

log_file = os.path.join(args.local_dir, "_log.txt")

dbx = None


def write_to_log(msg):
    print(msg)
    with open(log_file, 'a') as fd:
        fd.write(msg)
    upload_log_to_dropbox()


def write_to_log_start(msg):
    write_to_log(f'{datetime.now().strftime("%d/%m/%Y %H:%M:%S")} START: {msg}\n')


def write_to_log_end(msg):
    write_to_log(f'{datetime.now().strftime("%d/%m/%Y %H:%M:%S")} END: {msg}\n')


def write_to_log_ts(msg, is_error: bool):
    if is_error:
        write_to_log(f'{datetime.now().strftime("%d/%m/%Y %H:%M:%S")} ERROR: {msg}\n')
    else:
        write_to_log(f'{datetime.now().strftime("%d/%m/%Y %H:%M:%S")} INFO: {msg}\n')


if args.dbox_token is not None:
    try:
        dbx = dropbox.Dropbox(args.dbox_token)
    except Exception:
        write_to_log_ts(traceback.format_exc(), True)


def execute_command(cmd) -> bool:
    try:
        write_to_log_start(cmd)
        os.system(cmd)
        return True
    except Exception:
        write_to_log_ts(traceback.format_exc(), True)
        return False
    finally:
        write_to_log_end(cmd)


def upload(file_to_upload, folder, subfolder, name, overwrite=False):
    # https://github.com/dropbox/dropbox-sdk-python/blob/master/example/updown.py
    path = '/%s/%s/%s' % (folder, subfolder.replace(os.path.sep, '/'), name)
    while '//' in path:
        path = path.replace('//', '/')

    mode = (dropf.WriteMode.overwrite
            if overwrite
            else dropf.WriteMode.add)
    mtime = os.path.getmtime(file_to_upload)
    with open(file_to_upload, 'rb') as f:
        data = f.read()
    try:
        res = dbx.files_upload(
            data, path, mode,
            client_modified=datetime(*time.gmtime(mtime)[:6]),
            mute=True)
        print('uploaded as', res.name.encode('utf8'))
        return res
    except ApiError as err:
        write_to_log_ts('Dropbox error: ' + err.error, True)
        return None
    except Exception:
        write_to_log_ts('Dropbox general error: ' + traceback.format_exc(), True)


def upload_log_to_dropbox():
    if dbx is None:
        return
    # Upload log file
    upload(log_file, args.dbox_dir, '', "log.txt", True)


def upload_to_dropbox(run_result_folder, experiment_name):
    cleanup_only = False
    if dbx is None:
        cleanup_only = True

    # Upload relevant experiment files
    f_result_prefix = 's.out.tfevents.'

    for root, dirs, files in os.walk(run_result_folder):
        uploaded_marker_file = os.path.join(root, '__processed_results_flag.txt')
        if os.path.isfile(uploaded_marker_file):
            continue  # this directory was already uploaded

        relevant_file = [s for s in files if s.startwith(f_result_prefix)]
        if any(relevant_file):
            full_f_result = os.path.join(root, relevant_file)
            if not cleanup_only:
                # If Dropbox upload is active for this run upload relevant files
                if os.path.isfile(full_f_result):
                    upload(full_f_result, args.dbox_dir, experiment_name, relevant_file)
                else:
                    write_to_log_ts('File not found: ' + full_f_result, False)
            try:
                # mark dir as uploaded
                with open(uploaded_marker_file, 'w') as f:
                    f.write(datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
                # Cleanup the results folder, leave only files that are actually relevant
                # remove irrelevant files
                for name in files:
                    if name != full_f_result:
                        os.remove(os.path.join(root, name))
                # remove folders
                for name in dirs:
                    os.rmdir(os.path.join(root, name))
            except Exception as err:
                print(err)
                write_to_log_ts(traceback.format_exc(), True)


maac_results_folder = os.path.join(args.local_dir, "maac/")

# Varying replay buffer
var_replay_buffer_variations = [1000000, 100000, 10000]  # first one is the default value
var_rb_res_folder = os.path.join(maac_results_folder, "rb/")
for scenario in scenarios:
    for rb_var in var_replay_buffer_variations:
        c_run_title = "maac_{}_rb_{}".format(scenario, rb_var)
        c_folder = os.path.join(var_rb_res_folder, c_run_title)
        for pfx in range(args.repeat):
            ivk_cmd = "python main.py " \
                      "--env_id={} " \
                      "--model_name={} " \
                      "--model_dir={} " \
                      "--buffer_length={}" \
                .format(scenario,
                        scenario,
                        "{}_{}".format(c_folder, str(pfx)),
                        rb_var)
            if args.use_gpu:
                ivk_cmd += "--use_gpu "

            if execute_command(ivk_cmd):
                upload_to_dropbox(c_folder, 'maac/{}_{}'.format(c_run_title, pfx))

# Standard experiments with varying gamma
var_gamma_variations = [0.95, 0.75, 0.50, 0.35, 0.15]
var_gamma_res_folder = os.path.join(maac_results_folder, "gamma/")
for scenario in scenarios:
    for gamma_var in var_gamma_variations:
        c_run_title = "maac_{0}_gamma_{1:1.2e}".format(scenario, gamma_var)
        c_folder = os.path.join(var_gamma_res_folder, c_run_title)
        for pfx in range(args.repeat):
            ivk_cmd = "python main.py " \
                      "--env_id={} " \
                      "--model_name={} " \
                      "--model_dir={} " \
                      "--gamma={}"\
                .format(scenario,
                        scenario,
                        "{}_{}".format(c_folder, str(pfx)),
                        gamma_var)
            if args.use_gpu:
                ivk_cmd += "--use_gpu "

            if execute_command(ivk_cmd):
                upload_to_dropbox(c_folder, 'maac/{}_{}'.format(c_run_title, pfx))

# Standard experiments with varying learning rate
var_lr_variations = [1e-3, 1e-2, 1e-1, 1, 1e+1, 1e+2]
var_lr_res_folder = os.path.join(maac_results_folder, "lr/")
for scenario in scenarios:
    for lr_var in var_lr_variations:
        c_run_title = "maac_{0}_lr_{1:1.2e}".format(scenario, lr_var)
        c_folder = os.path.join(var_lr_res_folder, c_run_title)
        for pfx in range(args.repeat):
            ivk_cmd = "python main.py " \
                      "--env_id={} " \
                      "--model_name={} " \
                      "--model_dir={} " \
                      "--pi_lr={}" \
                      "--q_lr={}" \
                .format(scenario,
                        scenario,
                        "{}_{}".format(c_folder, str(pfx)),
                        lr_var, lr_var)
            if args.use_gpu:
                ivk_cmd += "--use_gpu "

            if execute_command(ivk_cmd):
                upload_to_dropbox(c_folder, 'maac/{}_{}'.format(c_run_title, pfx))

# Default parameters
default_scen_folder = os.path.join(maac_results_folder, "default/")
for scenario in scenarios:
    c_run_title = "maac_{}".format(scenario)
    c_folder = os.path.join(default_scen_folder, c_run_title)
    for pfx in range(args.repeat):
        ivk_cmd = "python main.py " \
                  "--env_id={} " \
                  "--model_name={} " \
                  "--model_dir={} " \
            .format(scenario,
                    scenario,
                    "{}_{}".format(c_folder, str(pfx)))
        if args.use_gpu:
            ivk_cmd += "--use_gpu "

        if execute_command(ivk_cmd):
            upload_to_dropbox(c_folder, 'maac/{}_{}'.format(c_run_title, pfx))
