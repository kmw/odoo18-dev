{
    'name': 'User Photo Albums',
    'version': '1.0',
    'category': 'Website',
    'summary': 'Allow users to create photo albums with tags and categories',
    'author': 'Your Name',
    'website': 'https://www.yourwebsite.com',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'web',
        'portal',
        'mail',
    ],
    'data': [
        'security/photo_album_security.xml',
        'security/ir.model.access.csv',
        'views/photo_album_views.xml',
        'views/photo_views.xml',
        'views/photo_category_views.xml',
        'views/templates.xml',
    ],
    'assets': {
        'web.assets_backend': [
            '/user_photo_albums/static/src/scss/photo_album.scss',
            '/user_photo_albums/static/src/js/photo_upload.js',
        ],
    },
    'installable': True,
    'application': True,
    'auto_install': False,
}
