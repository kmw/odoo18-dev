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
