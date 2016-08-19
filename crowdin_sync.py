#!/usr/bin/env python
# -*- coding: utf-8 -*-
# crowdin_sync.py
#
# Updates Crowdin source translations and pushes translations
# directly to PureNexus Github.
#
# Copyright (C) 2014-2015 The CyanogenMod Project
# This code has been modified. Portions copyright (C) 2016, The PAC-ROM Project
# This code has been modified. Portions copyright (C) 2016, The Pure Nexus Project

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ################################# IMPORTS ################################## #

from __future__ import print_function

import argparse
import git
import os
import subprocess
import sys

from xml.dom import minidom

# ################################# GLOBALS ################################## #

_DIR = os.path.dirname(os.path.realpath(__file__))

# ################################ FUNCTIONS ################################# #


def run_subprocess(cmd, silent=False):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                         universal_newlines=True)
    comm = p.communicate()
    exit_code = p.returncode
    if exit_code != 0 and not silent:
        print("There was an error running the subprocess.\n"
              "cmd: %s\n"
              "exit code: %d\n"
              "stdout: %s\n"
              "stderr: %s" % (cmd, exit_code, comm[0], comm[1]),
              file=sys.stderr)
    return comm, exit_code


def push_as_commit(base_path, path, name, branch, username):
    print('Committing %s on branch %s' % (name, branch))

    # Get path
    path = os.path.join(base_path, path)
    if not path.endswith('.git'):
        path = os.path.join(path, '.git')

    # Create repo object
    repo = git.Repo(path)

    # Remove previously deleted files from Git
    files = repo.git.ls_files(d=True).split('\n')
    if files and files[0]:
        repo.git.rm(files)

    # Add all files to commit
    repo.git.add('-A')

    # Create commit; if it fails, probably empty so skipping
    try:
        repo.git.commit(m='PureNexus Automatic translation import')
    except:
        print('Failed to create commit for %s, probably empty: skipping'
              % name, file=sys.stderr)
        return

    # Push commit
    try:
        repo.git.push('git@github.com:PureNexusProject-Legacy/%s' % (name),
                      'HEAD:%s' % branch)
        print('Successfully pushed commit for %s' % name)
    except:
        print('Failed to push commit for %s' % name, file=sys.stderr)


def check_run(cmd):
    p = subprocess.Popen(cmd, stdout=sys.stdout, stderr=sys.stderr)
    ret = p.wait()
    if ret != 0:
        print('Failed to run cmd: %s' % ' '.join(cmd), file=sys.stderr)
        sys.exit(ret)


def find_xml(base_path):
    for dp, dn, file_names in os.walk(base_path):
        for f in file_names:
            if os.path.splitext(f)[1] == '.xml':
                yield os.path.join(dp, f)

# ############################################################################ #


def parse_args():
    parser = argparse.ArgumentParser(
        description="Synchronising PureNexus translations with Crowdin")
    sync = parser.add_mutually_exclusive_group()
    parser.add_argument('-u', '--username', help='Git username',
                        required=True)
    parser.add_argument('-b', '--branch', help='Pure branch',
                        required=True)
    sync.add_argument('--no-upload', action='store_true',
                      help='Only download PureNexus translations from Crowdin')
    sync.add_argument('--no-download', action='store_true',
                      help='Only upload PureNexus source translations to Crowdin')
    return parser.parse_args()

# ################################# PREPARE ################################## #


def check_dependencies():
    # Check for Ruby version of crowdin-cli
    cmd = ['gem', 'list', 'crowdin-cli', '-i']
    if run_subprocess(cmd, silent=True)[1] != 0:
        print('You have not installed crowdin-cli.', file=sys.stderr)
        return False
    return True


def load_xml(x):
    try:
        return minidom.parse(x)
    except IOError:
        print('You have no %s.' % x, file=sys.stderr)
        return None
    except Exception:
        # TODO: minidom should not be used.
        print('Malformed %s.' % x, file=sys.stderr)
        return None


def check_files(branch):
    files = ['%s/crowdin/crowdin_%s.yaml' % (_DIR, branch)]
    for f in files:
        if not os.path.isfile(f):
            print('You have no %s.' % f, file=sys.stderr)
            return False
    return True

# ################################### MAIN ################################### #


def upload_crowdin(branch, no_upload=False):
    if no_upload:
        print('Skipping source translations upload')
        return

    print('\nUploading Crowdin source translations')
    check_run(['crowdin-cli',
               '--config=%s/crowdin/crowdin_%s.yaml' % (_DIR, branch),
               'upload', 'sources'])


def download_crowdin(base_path, branch, xml, username, no_download=False):
    if no_download:
        print('Skipping translations download')
        return

    print('\nDownloading Crowdin translations')
    check_run(['crowdin-cli',
               '--config=%s/crowdin/crowdin_%s.yaml' % (_DIR, branch),
               'download', '--ignore-match'])


    print('\nRemoving useless empty translation files')
    empty_contents = {
        '<resources/>',
        '<resources xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2"/>',
        ('<resources xmlns:android='
         '"http://schemas.android.com/apk/res/android"/>'),
        ('<resources xmlns:android="http://schemas.android.com/apk/res/android"'
         ' xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2"/>'),
        ('<resources xmlns:tools="http://schemas.android.com/tools"'
         ' xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2"/>')
    }
    xf = None
    for xml_file in find_xml(base_path):
        xf = open(xml_file).read()
        for line in empty_contents:
            if line in xf:
                print('Removing ' + xml_file)
                os.remove(xml_file)
                break
    del xf

    print('\nCreating a list of pushable translations')
    # Get all files that Crowdin pushed
    paths = []
    files = [('%s/crowdin/crowdin_%s.yaml' % (_DIR, branch))]
    for c in files:
        cmd = ['crowdin-cli', '--config=%s' % c, 'list', 'sources']
        comm, ret = run_subprocess(cmd)
        if ret != 0:
            sys.exit(ret)
        for p in str(comm[0]).split("\n"):
            paths.append(p.replace('/%s' % branch, ''))

    print('\nUploading translations to Github')
    xml_android = load_xml(x='%s/manifest/default.xml' % base_path)
    items = xml_android.getElementsByTagName('project')
    #items = [x for sub in xml for x in sub.getElementsByTagName('project')]
    all_projects = []

    for path in paths:
        path = path.strip()
        if not path:
            continue

        if "/res" not in path:
            print('WARNING: Cannot determine project root dir of '
                  '[%s], skipping.' % path)
            continue
        result = path.split('/res')[0].strip('/')
        if result == path.strip('/'):
            print('WARNING: Cannot determine project root dir of '
                  '[%s], skipping.' % path)
            continue

        if result in all_projects:
            continue

        # When a project has multiple translatable files, Crowdin will
        # give duplicates.
        # We don't want that (useless empty commits), so we save each
        # project in all_projects and check if it's already in there.
        all_projects.append(result)

        # Search android/default.xml or crowdin/extra_packages_%(branch).xml
        # for the project's name
        for project in items:
            path = project.attributes['path'].value
            if not (result + '/').startswith(path +'/'):
                continue
            if result != path:
                if path in all_projects:
                    break
                result = path
                all_projects.append(result)

            br = project.getAttribute('revision') or branch

            push_as_commit(base_path, result,
                           project.getAttribute('name'), br, username)
            break


def main():
    args = parse_args()
    default_branch = args.branch

    base_path = os.getenv('PURE_CROWDIN_BASE_PATH')
    if base_path is None:
        cwd = os.getcwd()
        print('You have not set PURE_CROWDIN_BASE_PATH. Defaulting to %s' % cwd)
        base_path = cwd
    else:
        base_path = os.path.join(os.path.realpath(base_path))
    if not os.path.isdir(base_path):
        print('PURE_CROWDIN_BASE_PATH + branch is not a real directory: c'
              % base_path)
        sys.exit(1)

    if not check_dependencies():
        sys.exit(1)

    xml_android = load_xml(x='%s/manifest/default.xml' % base_path)
    if xml_android is None:
        sys.exit(1)

    if not check_files(default_branch):
        sys.exit(1)

    upload_crowdin(default_branch, args.no_upload)
    download_crowdin(base_path, default_branch, (xml_android),
                     args.username, args.no_download)
    print('\nDone!')

if __name__ == '__main__':
    main()
