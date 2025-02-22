from odoo import models, fields, api

class ProfessionalPortfolio(models.Model):
    _name = 'professional.portfolio'
    _description = 'Professional Portfolio'
    _inherit = ['website.published.mixin']

    name = fields.Char(required=True)
    naics_ids = fields.Many2many('naics.code', string='NAICS Codes')
    blog_post_ids = fields.One2many('blog.post', 'portfolio_id', string='Blog Posts')
    description = fields.Html('Description')
    experience_summary = fields.Text('Experience Summary')
