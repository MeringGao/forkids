"""
这个是从古诗文网进行的爬取
"""
import aiohttp
import asyncio
import json
import re
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

HOST = 'https://so.gushiwen.org'

# 唐诗首页
TANGSHIHOME = '/gushi/tangshi.aspx'
SONGCIHOME = '/gushi/songsan.aspx'

# 诗词内容
DETAILCONTURL = 'https://so.gushiwen.org/shiwen2017/ajaxshiwencont.aspx?id={poet_id}&value=cont'
# 赏析
DETAILSHANGURL = 'https://so.gushiwen.org/shiwen2017/ajaxshiwencont.aspx?id={poet_id}&value=shang'
# 翻译
DETAILYIURL = 'https://so.gushiwen.org/shiwen2017/ajaxshiwencont.aspx?id={poet_id}&value=yi'
# 注释
DETAILZHUURL = 'https://so.gushiwen.org/shiwen2017/ajaxshiwencont.aspx?id={poet_id}&value=zhu'

YI_RE = re.compile(r'<span style="color:#76621c;">(.*)<br /></span>')
ZHU_RE = re.compile(r'<br /><span style="color:#286345;">(.*)>{0}</span>')
ZHU_ITEM_RE = re.compile(r'([^。]*?)：([^：]*。)')
SHANG_RE = re.compile(r'<p>(.*?)</p>')


async def fetch(url, headers=None):
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=headers) as response:
            return await response.text()


async def extract_cont(poet_id, headers):
    cont_html = await fetch(DETAILCONTURL.format(poet_id=poet_id), headers)
    cont = cont_html.replace('<br />', '\n')
    return cont


async def extract_yi(poet_id, headers):
    yi_html = await fetch(DETAILYIURL.format(poet_id=poet_id), headers)
    yi_list = YI_RE.findall(yi_html)
    return yi_list


async def extract_zhu(poet_id, headers):
    zhu_html = await fetch(DETAILZHUURL.format(poet_id=poet_id), headers)
    zhu_blocks = ZHU_RE.findall(zhu_html)
    zhu = []
    for zhu_block in zhu_blocks:
        zhu_list = ZHU_ITEM_RE.findall(zhu_block)
        for item in zhu_list:
            zhu.append({"key": item[0], "value": item[1]})
    return zhu


async def extract_shang(poet_id, headers):
    shang_html = await fetch(DETAILSHANGURL.format(poet_id=poet_id), headers)
    shang_html = shang_html.replace('\u3000', '')
    shang_list = SHANG_RE.findall(shang_html)
    return shang_list


async def get_tangshi_detail(url):
    """
    Args:
        - url : tuple
            - 0: link
            - 1: title
            - 2: author
    """
    headers = {
        'sec-fetch-mode': 'cors',
        'accept-encoding': 'gzip, deflate, br',
        'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-TW;q=0.6,ja;q=0.5',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36',
        'accept': '*/*',
        'referer': f'https://so.gushiwen.org{url[0]}',
        'authority': 'so.gushiwen.org',
        'cookie': 'Hm_lvt_04660099568f561a75456483228a9516=1566870930; ASP.NET_SessionId=4ztkoghh5fudcefjvjdxnmpp; Hm_lpvt_04660099568f561a75456483228a9516=1566885768',
        'sec-fetch-site': 'same-origin'}
    poet_id = url[0].replace('/shiwenv_', '').replace('.aspx', '')
    cont = await extract_cont(poet_id, headers)
    yi = await extract_yi(poet_id, headers)
    zhu = await extract_zhu(poet_id, headers)
    shangxi = await extract_shang(poet_id, headers)
    poet = dict()
    poet['title'] = url[1]
    poet['author'] = url[2]
    poet['cont'] = cont
    poet['yi'] = yi
    poet['zhu'] = zhu
    poet['shangxi'] = shangxi
    return poet


async def get_tangshi_list():
    link_re = re.compile(
        r'<span><a href="(?P<link>.*)" target="_blank">(?P<title>.*)</a>\((?P<author>.*)\)</span>')

    html = await fetch(f'{HOST}{TANGSHIHOME}')
    links = link_re.findall(html)
    poets = []
    for link in links:
        poet = await get_tangshi_detail(link)
        print(link)
        poets.append(poet)
    return poets


async def get_songci_list():
    link_re = re.compile(
        r'<span><a href="(?P<link>.*)" target="_blank">(?P<title>.*)</a>\((?P<author>.*)\)</span>')

    html = await fetch(f'{HOST}{SONGCIHOME}')
    links = link_re.findall(html)
    poets = []
    for link in links:
        poet = await get_tangshi_detail(link)
        print(link)
        poets.append(poet)
    return poets


async def main():
    tangshi300 = await get_tangshi_list()
    with open(os.path.join(BASE_DIR, 'datas/tangshi300.json'), 'w', encoding='utf-8') as f:
        f.write(json.dumps(tangshi300))


loop = asyncio.get_event_loop()
loop.run_until_complete(main())
