#!/bin/bash

# Set the root directory
ROOT_DIR="/home/kmw/PycharmProjects/photo-module"
MODULE_DIR="$ROOT_DIR/custom_addons/user_photo_albums"

# Create directory structure
echo "Creating directory structure..."
mkdir -p $MODULE_DIR/{models,views,security,controllers,static/{src/{js,scss},description}}

# Create and populate __init__.py files
echo "Creating initialization files..."
echo "from . import models
from . import controllers" > "$MODULE_DIR/__init__.py"

echo "from . import photo_album
from . import photo_category
from . import photo" > "$MODULE_DIR/models/__init__.py"

# Create manifest file
echo "Creating manifest file..."
cat > "$MODULE_DIR/__manifest__.py" << 'EOF'
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
        'website',
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
        'web.assets_frontend': [
            'user_photo_albums/static/src/js/photo_upload.js',
            'user_photo_albums/static/src/scss/photo_album.scss',
        ],
    },
    'installable': True,
    'application': True,
    'auto_install': False,
}
EOF

# Create photo_category.py
echo "Creating photo category model..."
cat > "$MODULE_DIR/models/photo_category.py" << 'EOF'
from odoo import api, fields, models

class PhotoCategory(models.Model):
    _name = 'photo.category'
    _description = 'Photo Category'
    _order = 'name'

    name = fields.Char(string='Category Name', required=True, translate=True)
    description = fields.Text(string='Description', translate=True)
    parent_id = fields.Many2one('photo.category', string='Parent Category')
    child_ids = fields.One2many('photo.category', 'parent_id', string='Child Categories')
    photo_ids = fields.Many2many('photo.photo', string='Photos')
    active = fields.Boolean(default=True)
    
    _sql_constraints = [
        ('name_uniq', 'unique (name)', "Category name already exists!"),
    ]
EOF

# Create photo_album.py
echo "Creating photo album model..."
cat > "$MODULE_DIR/models/photo_album.py" << 'EOF'
from odoo import api, fields, models
from odoo.exceptions import ValidationError

class PhotoAlbum(models.Model):
    _name = 'photo.album'
    _description = 'Photo Album'
    _inherit = ['portal.mixin', 'mail.thread', 'mail.activity.mixin']
    _order = 'date_created desc'

    name = fields.Char(string='Album Name', required=True, tracking=True)
    description = fields.Text(string='Description', tracking=True)
    date_created = fields.Datetime(string='Created On', default=fields.Datetime.now, readonly=True)
    user_id = fields.Many2one('res.users', string='Created By', default=lambda self: self.env.user, readonly=True)
    photo_ids = fields.One2many('photo.photo', 'album_id', string='Photos')
    photo_count = fields.Integer(compute='_compute_photo_count', string='Photo Count', store=True)
    is_public = fields.Boolean(string='Public Album', default=False, tracking=True)
    cover_photo_id = fields.Many2one('photo.photo', string='Cover Photo')
    active = fields.Boolean(default=True)

    @api.depends('photo_ids')
    def _compute_photo_count(self):
        for album in self:
            album.photo_count = len(album.photo_ids)

    @api.model
    def create(self, vals):
        if not self.env.user.id:
            raise ValidationError('You must be logged in to create an album')
        return super(PhotoAlbum, self).create(vals)

    def _compute_access_url(self):
        super(PhotoAlbum, self)._compute_access_url()
        for album in self:
            album.access_url = f'/my/albums/{album.id}'

    def action_toggle_public(self):
        for record in self:
            record.is_public = not record.is_public
EOF

echo "First part of module setup complete!"
