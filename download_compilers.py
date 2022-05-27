import requests
import os, stat
from aiostream import stream
from aiofile import async_open
import aiohttp
import asyncio
from vvm.install import get_installable_vyper_versions, get_installed_vyper_versions
from vvm.install import _get_releases as get_vvm_releases
from solcx.install import get_installable_solc_versions, get_installed_solc_versions


solc_url_prefix = "https://solc-bin.ethereum.org/linux-amd64/"
home_directory = os.environ.get("HOME")
urls_to_version = {}

async def process_write(data):
    file_name = data['file_name']
    to_write = data['to_write']

    async with async_open(file_name, "wb+") as f:
        await f.write(to_write)
        st = os.stat(file_name)
        os.chmod(file_name, st.st_mode | stat.S_IEXEC)

    print(f"done writing {file_name}")

async def fetch(session, url):
    global urls_to_version
    async with session.get(url) as resp:
        print(f"url is {url}, status is {resp.status}")
        res = {}
        res['file_name'] = urls_to_version[url]
        res['to_write'] = await resp.read()
        return res

async def hydrate_compiler_cache(download_urls):
    async with aiohttp.ClientSession() as session:
        ws = stream.repeat(session)
        xs = stream.zip(ws, stream.iterate(download_urls))
        ys = stream.starmap(xs, fetch, ordered=False, task_limit=30)
        zs = stream.map(ys, process_write)
        await zs

def replace_all(string, replace):
    for r in replace:
        string = string.replace(r, '')
    return string

if __name__ == '__main__':
    versions = get_installable_vyper_versions()
    installed_versions = get_installed_vyper_versions(os.path.join(home_directory, '.vvm'))
    versions = [version for version in versions if version not in installed_versions]
    releases = get_vvm_releases(None)
    download_urls = []
    for release in releases:
        for asset in release['assets']:
            if asset['name'].endswith('linux'):
                download_urls.append(asset['browser_download_url'])
                version_ender = 'vyper-' + replace_all(release['name'], ['v', ' ', 'Vyper', 'Version'])
                print(version_ender)
                urls_to_version[asset['browser_download_url']] = os.path.join(home_directory, '.vvm', version_ender)

    versions = get_installable_solc_versions()

    installed_versions = get_installed_solc_versions(os.path.join(home_directory, '.solcx'))
    versions = [version for version in versions if version not in installed_versions]

    data = requests.get("https://solc-bin.ethereum.org/{}-amd64/{}".format("linux", "list.json"))
    releases = data.json()['releases']
    for version, ender in releases.items():
        if version in map(str, versions):
            url = solc_url_prefix + ender
            download_urls.append(url)
            urls_to_version[url] = os.path.join(home_directory, '.solcx', 'solc-v' + version)

    asyncio.run(hydrate_compiler_cache(download_urls))