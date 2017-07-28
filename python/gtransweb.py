#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import os.path
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
try:
    from urllib import quote_plus
except ImportError:
    from urllib.parse import quote_plus

USER_AGENT = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:40.0) ' + \
             'Gecko/20100101 Firefox/40.0'


def fetch_args_vim():
    import vim
    src_lang = vim.eval('g:gtransweb_src_lang')
    tgt_lang = vim.eval('g:gtransweb_tgt_lang')
    src_text = vim.eval('s:src_text')
    return src_lang, tgt_lang, src_text


def return_result_vim(tgt_text):
    import vim
    tgt_text = tgt_text.replace('"', '\'')  # Escape quote
    vim.command('let s:tgt_text = "' + tgt_text + '"')


def create_driver():
    driver = webdriver.PhantomJS(
        service_log_path=os.path.devnull,
        desired_capabilities={
            'phantomjs.page.settings.userAgent': USER_AGENT
        })
    return driver


def gtrans_search(driver, src_lang, tgt_lang, src_text):
    # Encode for URL
    src_text = quote_plus(src_text)

    # Clear webpage
    driver.get('about:blank')
    WebDriverWait(driver, 10).until(EC.title_is(''))

    # Load webpage
    url_exp = "https://translate.google.com/#{}/{}/{}"
    url = url_exp.format(src_lang, tgt_lang, src_text)
    driver.get(url)

    # Find result text
    try:
        result_box = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.ID, 'result_box')))
        inner_spans = result_box.find_elements_by_tag_name("span")
        texts = [s.text for s in inner_spans]
        text = '\n'.join(texts)
    except Exception:
        import traceback
        traceback.print_exc()
        return 'Error: Failed to scrape google translation website.'

    return text


if __name__ == "__main__":
    # Argument
    parser = argparse.ArgumentParser(description='gtrans-web')
    parser.add_argument('--mode', choices=['vim', 'alone'], default='vim')
    parser.add_argument('--src_lang', type=str, default='auto',
                        help='Source language in `alone` mode')
    parser.add_argument('--tgt_lang', type=str, default='auto',
                        help='Target language in `alone` mode')
    parser.add_argument('--src_text', type=str, default='This is a pen.',
                        help='Srouce text in `alone` mode')
    args = parser.parse_args()

    # Text and language information
    if args.mode == 'vim':
        src_lang, tgt_lang, src_text = fetch_args_vim()
    else:
        src_lang, tgt_lang, src_text = \
                args.src_lang, args.tgt_lang, args.src_text

    try:
        # Create PhantomJS driver
        driver = create_driver()
    except Exception:
        tgt_text = 'Error: PhantomJS may not be installed.'
    finally:
        # Access translate.google.com
        tgt_text = gtrans_search(driver, src_lang, tgt_lang, src_text)
        # Close driver
        driver.close()

    # Result
    if args.mode == 'vim':
        return_result_vim(tgt_text)
    else:
        print(tgt_text)
