from odoo import models, fields

class NaicsCode(models.Model):
    _name = 'naics.code'
    _description = 'NAICS Code'

    name = fields.Char('Description', required=True)
    code = fields.Char('NAICS Code', required=True)
    portfolio_ids = fields.Many2many('professional.portfolio', string='Portfolios')
    blog_post_ids = fields.Many2many('blog.post', string='Related Blog Posts')
