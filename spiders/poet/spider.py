"""
这个是从古诗文网进行的爬取
"""

import aiohttp
import asyncio
import re
from bs4 import BeautifulSoup


HOST = 'https://so.gushiwen.org'

# 唐诗首页
TANGSHIHOME = '/gushi/tangshi.aspx'

# 赏析地址
SHANGXIHOST = 'https://so.gushiwen.org/shiwen2017/ajaxshangxi.aspx?id={id}'
# 赏析地址 请求头
SHANGXIHEADERS = {
    # ':authority': 'so.gushiwen.org',
    # 'referer': 'https://so.gushiwen.org/shiwenv_45c396367f59.aspx',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36'
}


async def fetch(url, headers=None):
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=headers) as response:
            return await response.text()


async def get_tangshi_detail(url):
    print(url)
    fanyi_re = re.compile(r'<p>(?:<strong>译文</strong>|译文)<br />(.*)</p>')
    zhushi_re = re.compile(r'<p>(?:<strong>注释</strong>|注释)<br />(.*)</p>')
    shangxiid_re = re.compile(
        r'<a style="text-decoration:none;" href="javascript:shangxiShow\((\d+)\)">展开阅读全文 ∨</a>')
    html = await fetch(f'{HOST}{url}')
    fanyi = fanyi_re.findall(html)[0].replace('<br />', '\n')
    zhushi = zhushi_re.findall(html)[0].replace('<br />', '\n')
    headers = {
        'pragma': 'no-cache',
        'cookie': 'Hm_lvt_04660099568f561a75456483228a9516=1566823011; ASP.NET_SessionId=421wuci0yygj0pojwzvco5cp; codeyzgswso=6cad65c0e49c9662; Hm_lpvt_04660099568f561a75456483228a9516=1566828029',
        'authority': 'so.gushiwen.org',
        'referer': f'{HOST}{url}',
        'accept-encoding': 'gzip, deflate, br',
        'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-TW;q=0.6,ja;q=0.5',
        'accept': '*/*',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36'
    }
    shangxihtml = await fetch(SHANGXIHOST.format(id=shangxiid_re.findall(html)[0]), headers)
    bs = BeautifulSoup(shangxihtml)
    div = bs.find('div', attrs={'class': 'contyishang'})
    shangxi = ''
    for p in div.findAll('p'):
        shangxi += p.text

    print(fanyi)
    print(zhushi)
    print(shangxi)


async def get_tangshi_list():
    link_re = re.compile(
        r'<span><a href="(?P<link>.*)" target="_blank">(?P<title>.*)</a>\((?P<author>.*)\)</span>')

    html = await fetch(f'{HOST}{TANGSHIHOME}')
    links = link_re.findall(html)
    for link in links:
        await get_tangshi_detail(link[0])


async def main():
    await get_tangshi_list()

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
