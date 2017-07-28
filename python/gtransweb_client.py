#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import socket
import time
import pickle

try:
    ConnectionRefusedError
except NameError:
    ConnectionRefusedError = socket.error

# This script cannot use local import basically because of vim.

# TODO: Make the following configurable
BUF_SIZE = 4096
N_TRIAL = 10


def fetch_args_vim():
    import vim
    src_lang = vim.eval('g:gtransweb#src_lang')
    tgt_lang = vim.eval('g:gtransweb#tgt_lang')
    src_text = vim.eval('s:src_text')
    port = int(vim.eval('g:gtransweb#server_port'))
    persist = vim.eval('s:client_persist')
    return src_lang, tgt_lang, src_text, port, persist


def return_result_vim(tgt_text, awoken):
    import vim
    tgt_text = tgt_text.replace('"', '\'')  # Escape quote
    vim.command('let s:tgt_text = "' + tgt_text + '"')
    vim.command('let s:server_awoken = {}'.format(int(awoken)))


def connect_gtrans_server(host, port, src_lang, tgt_lang, src_text):
    # Connect to the server
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((host, port))

    # Send serialized data
    src_text = src_text.decode('utf-8')
    data = (src_lang, tgt_lang, src_text)
    data = pickle.dumps(data, protocol=2)
    client.sendall(data)

    # Receive result
    data = client.recv(BUF_SIZE)

    # Deserialize
    tgt_text = pickle.loads(data)
    return tgt_text


if __name__ == '__main__':
    # Argument
    parser = argparse.ArgumentParser(description='gtrans-web')
    parser.add_argument('--mode', choices=['vim', 'alone'], default='vim')
    parser.add_argument('--src_lang', type=str, default='auto',
                        help='Source language in `alone` mode')
    parser.add_argument('--tgt_lang', type=str, default='auto',
                        help='Target language in `alone` mode')
    parser.add_argument('--src_text', type=str, default='This is a pen.',
                        help='Srouce text in `alone` mode')
    parser.add_argument('--port', type=int, default=23148,
                        help='Port number in `alone` mode')
    parser.add_argument('--persist', default=True, action='store_true',
                        help='Persistent mode')
    args = parser.parse_args()

    # Text, language and port number
    if args.mode == 'vim':
        src_lang, tgt_lang, src_text, port, persist = fetch_args_vim()
    else:
        src_lang, tgt_lang, src_text, port, persist = (
                args.src_lang, args.tgt_lang, args.src_text, args.port,
                args.persist)

    # Connect to server
    for _ in range(N_TRIAL):
        try:
            tgt_text = connect_gtrans_server('localhost', port, src_lang,
                                             tgt_lang, src_text)
            awoken = True
        except ConnectionRefusedError:
            tgt_text = ''
            awoken = False
        # Persist
        if not persist or awoken:
            break
        time.sleep(0.3)

    # Result
    if args.mode == 'vim':
        return_result_vim(tgt_text, awoken=awoken)
    else:
        if awoken:
            print(tgt_text)
        else:
            print('The server is not awoken.')
