from odoo import http
from odoo.http import request

class PortfolioController(http.Controller):
    @http.route(['/portfolio'], type='http', auth="public", website=True)
    def portfolio_index(self, **kw):
        portfolios = request.env['professional.portfolio'].search([])
        return request.render("professional_portfolio.portfolio_index", {
            'portfolios': portfolios
        })
