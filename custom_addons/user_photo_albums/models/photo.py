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
