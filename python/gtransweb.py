#!/usr/bin/env python
# -*- coding: utf-8 -*-

from selenium import webdriver
import urllib

USER_AGENT = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:40.0) ' + \
             'Gecko/20100101 Firefox/40.0'


def fetch_args_vim():
    import vim
    src_lang = vim.eval('s:src_lang')
    tgt_lang = vim.eval('s:tgt_lang')
    src_text = vim.eval('s:src_text')
    return src_lang, tgt_lang, src_text


def return_result_vim(t_text):
    import vim
    t_text = t_text.replace('"', '\'')  # Escape quote
    vim.command('let s:t_text = "' + t_text + '"')


def gtrans_search(src_lang, tgt_lang, src_text):
    # Remove newlines
    src_text = src_text.splitlines()
    src_text = ' '.join(src_text)
    # Encode for URL
    src_text = urllib.quote_plus(src_text)

    # Create PhantomJS driver
    try:
        driver = webdriver.PhantomJS(
                service_log_path="/dev/null",
                desired_capabilities={
                    'phantomjs.page.settings.userAgent': USER_AGENT
                })
    except Exception:
        return 'Error: PhantomJS is not installed.'

    # Load web page
    url_exp = "https://translate.google.com/#{}/{}/{}"
    url = url_exp.format(src_lang, tgt_lang, src_text)
    driver.get(url)

    # Find result text
    try:
        result_box = driver.find_element_by_id('result_box')
        inner_spans = result_box.find_elements_by_tag_name("span")
        texts = [s.text for s in inner_spans]
        text = '\n'.join(texts)
    except Exception:
        return 'Error: Failed to scrape google translation website.'

    # Close driver
    driver.close()

    return text


if __name__ == "__main__":
    s_lang, t_lang, s_text = fetch_args_vim()
    t_text = gtrans_search(s_lang, t_lang, s_text)
    return_result_vim(t_text)
