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
