#!/bin/bash

# Set the root directory
ROOT_DIR="/home/kmw/PycharmProjects/photo-module"
MODULE_DIR="$ROOT_DIR/custom_addons/user_photo_albums"

# Create photo.py
echo "Creating photo model..."
cat > "$MODULE_DIR/models/photo.py" << 'EOF'
from odoo import api, fields, models
import base64
from PIL import Image
import io

class Photo(models.Model):
    _name = 'photo.photo'
    _description = 'Photo'
    _inherit = ['portal.mixin', 'mail.thread', 'mail.activity.mixin']
    _order = 'date_uploaded desc'

    name = fields.Char(string='Title', required=True, tracking=True)
    description = fields.Text(string='Description', tracking=True)
    image = fields.Binary(string='Photo', required=True, attachment=True)
    image_medium = fields.Binary(string='Medium Photo', attachment=True, store=True, compute='_compute_images')
    image_small = fields.Binary(string='Thumbnail', attachment=True, store=True, compute='_compute_images')
    date_uploaded = fields.Datetime(string='Upload Date', default=fields.Datetime.now, readonly=True)
    user_id = fields.Many2one('res.users', string='Uploaded By', default=lambda self: self.env.user, readonly=True)
    album_id = fields.Many2one('photo.album', string='Album', required=True, ondelete='cascade', tracking=True)
    category_ids = fields.Many2many('photo.category', string='Categories', tracking=True)
    tag_ids = fields.Many2many('photo.tag', string='Tags', tracking=True)
    is_public = fields.Boolean(related='album_id.is_public', string='Public', store=True)
    active = fields.Boolean(default=True)
    view_count = fields.Integer(string='Views', default=0)
    
    @api.depends('image')
    def _compute_images(self):
        for photo in self:
            if photo.image:
                image_data = base64.b64decode(photo.image)
                img = Image.open(io.BytesIO(image_data))
                
                # Medium size (800x600 max)
                medium_size = (800, 600)
                img_medium = img.copy()
                img_medium.thumbnail(medium_size, Image.LANCZOS)
                buffer = io.BytesIO()
                img_medium.save(buffer, format=img.format or 'JPEG')
                photo.image_medium = base64.b64encode(buffer.getvalue())
                
                # Small thumbnail (200x200 max)
                small_size = (200, 200)
                img_small = img.copy()
                img_small.thumbnail(small_size, Image.LANCZOS)
                buffer = io.BytesIO()
                img_small.save(buffer, format=img.format or 'JPEG')
                photo.image_small = base64.b64encode(buffer.getvalue())
            else:
                photo.image_medium = False
                photo.image_small = False


class PhotoTag(models.Model):
    _name = 'photo.tag'
    _description = 'Photo Tag'
    
    name = fields.Char(string='Tag Name', required=True)
    photo_ids = fields.Many2many('photo.photo', string='Photos')
    frequency = fields.Integer(compute='_compute_frequency', store=True)
    color = fields.Integer(string='Color Index')
    
    @api.depends('photo_ids')
    def _compute_frequency(self):
        for tag in self:
            tag.frequency = len(tag.photo_ids)
EOF

# Create security files
echo "Creating security files..."

# Create ir.model.access.csv
cat > "$MODULE_DIR/security/ir.model.access.csv" << 'EOF'
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_photo_album_user,photo.album user,model_photo_album,base.group_user,1,1,1,1
access_photo_photo_user,photo.photo user,model_photo_photo,base.group_user,1,1,1,1
access_photo_category_user,photo.category user,model_photo_category,base.group_user,1,1,1,0
access_photo_tag_user,photo.tag user,model_photo_tag,base.group_user,1,1,1,1
EOF

# Create photo_album_security.xml
cat > "$MODULE_DIR/security/photo_album_security.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="0">
        <record id="module_category_photo_albums" model="ir.module.category">
            <field name="name">Photo Albums</field>
            <field name="description">Manage photo albums and images</field>
            <field name="sequence">20</field>
        </record>

        <record id="group_photo_album_user" model="res.groups">
            <field name="name">User</field>
            <field name="category_id" ref="module_category_photo_albums"/>
            <field name="implied_ids" eval="[(4, ref('base.group_user'))]"/>
        </record>

        <record id="group_photo_album_manager" model="res.groups">
            <field name="name">Manager</field>
            <field name="category_id" ref="module_category_photo_albums"/>
            <field name="implied_ids" eval="[(4, ref('group_photo_album_user'))]"/>
            <field name="users" eval="[(4, ref('base.user_root')), (4, ref('base.user_admin'))]"/>
        </record>
    </data>

    <data noupdate="1">
        <record id="photo_album_personal_rule" model="ir.rule">
            <field name="name">Personal Albums</field>
            <field name="model_id" ref="model_photo_album"/>
            <field name="domain_force">[('user_id','=',user.id)]</field>
            <field name="groups" eval="[(4, ref('group_photo_album_user'))]"/>
        </record>

        <record id="photo_personal_rule" model="ir.rule">
            <field name="name">Personal Photos</field>
            <field name="model_id" ref="model_photo_photo"/>
            <field name="domain_force">[('user_id','=',user.id)]</field>
            <field name="groups" eval="[(4, ref('group_photo_album_user'))]"/>
        </record>

        <record id="photo_album_manager_rule" model="ir.rule">
            <field name="name">All Albums</field>
            <field name="model_id" ref="model_photo_album"/>
            <field name="domain_force">[(1,'=',1)]</field>
            <field name="groups" eval="[(4, ref('group_photo_album_manager'))]"/>
        </record>
    </data>
</odoo>
EOF

# Create controller files
echo "Creating controller files..."

# Create controllers/__init__.py
echo "from . import main" > "$MODULE_DIR/controllers/__init__.py"

# Create controllers/main.py
cat > "$MODULE_DIR/controllers/main.py" << 'EOF'
from odoo import http
from odoo.http import request

class PhotoAlbumController(http.Controller):
    @http.route(['/my/albums', '/my/albums/page/<int:page>'], type='http', auth="user", website=True)
    def portal_my_albums(self, page=1, **kw):
        domain = [('user_id', '=', request.env.user.id)]
        albums = request.env['photo.album'].search(domain)
        return request.render("user_photo_albums.portal_my_albums", {
            'albums': albums,
        })

    @http.route(['/my/albums/<int:album_id>'], type='http', auth="user", website=True)
    def portal_my_album(self, album_id, **kw):
        album = request.env['photo.album'].browse(album_id)
        if not album.exists() or album.user_id != request.env.user:
            return request.redirect('/my/albums')
        return request.render("user_photo_albums.portal_my_album", {
            'album': album,
        })
EOF

# Create empty placeholder files for views (to be filled later)
touch "$MODULE_DIR/views/photo_album_views.xml"
touch "$MODULE_DIR/views/photo_views.xml"
touch "$MODULE_DIR/views/photo_category_views.xml"
touch "$MODULE_DIR/views/templates.xml"

echo "Second part of module setup complete!"
