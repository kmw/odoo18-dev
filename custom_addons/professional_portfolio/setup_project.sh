# setup_project.sh
#!/bin/bash

# Make sure we're in the right directory
if [[ ! -d "professional_portfolio" ]]; then
    echo "Creating professional_portfolio directory..."
    mkdir -p professional_portfolio
fi

# Create manifest file
cat > professional_portfolio/__manifest__.py << 'EOL'
{
    'name': 'Professional Portfolio',
    'version': '1.0',
    'category': 'Website',
    'summary': 'Professional Portfolio with NAICS Integration',
    'sequence': 1,
    'author': 'Kenneth Wyrick',
    'website': 'https://caltek.net',
    'depends': [
        'base',
        'website',
        'website_blog',
        'hr_recruitment',
    ],
    'data': [
        'security/ir.model.access.csv',
        'views/portfolio_views.xml',
        'views/naics_views.xml',
        'views/templates.xml',
        'data/naics_data.xml',
    ],
    'installable': True,
    'application': True,
    'license': 'LGPL-3',
}
EOL

# Create root __init__.py
cat > professional_portfolio/__init__.py << 'EOL'
from . import models
from . import controllers
EOL

# Create models/__init__.py
cat > professional_portfolio/models/__init__.py << 'EOL'
from . import portfolio
from . import naics
EOL

# Create models/portfolio.py
cat > professional_portfolio/models/portfolio.py << 'EOL'
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
EOL

# Create models/naics.py
cat > professional_portfolio/models/naics.py << 'EOL'
from odoo import models, fields

class NaicsCode(models.Model):
    _name = 'naics.code'
    _description = 'NAICS Code'

    name = fields.Char('Description', required=True)
    code = fields.Char('NAICS Code', required=True)
    portfolio_ids = fields.Many2many('professional.portfolio', string='Portfolios')
    blog_post_ids = fields.Many2many('blog.post', string='Related Blog Posts')
EOL

# Create controllers/__init__.py
cat > professional_portfolio/controllers/__init__.py << 'EOL'
from . import main
EOL

# Create controllers/main.py
cat > professional_portfolio/controllers/main.py << 'EOL'
from odoo import http
from odoo.http import request

class PortfolioController(http.Controller):
    @http.route(['/portfolio'], type='http', auth="public", website=True)
    def portfolio_index(self, **kw):
        portfolios = request.env['professional.portfolio'].search([])
        return request.render("professional_portfolio.portfolio_index", {
            'portfolios': portfolios
        })
EOL

# Create security/ir.model.access.csv
cat > professional_portfolio/security/ir.model.access.csv << 'EOL'
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_professional_portfolio_public,professional.portfolio.public,model_professional_portfolio,,1,0,0,0
access_professional_portfolio_user,professional.portfolio.user,model_professional_portfolio,base.group_user,1,1,1,1
access_naics_code_public,naics.code.public,model_naics_code,,1,0,0,0
access_naics_code_user,naics.code.user,model_naics_code,base.group_user,1,1,1,1
EOL

# Create views directory if it doesn't exist
mkdir -p professional_portfolio/views

# Create views/portfolio_views.xml
cat > professional_portfolio/views/portfolio_views.xml << 'EOL'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <record id="view_portfolio_form" model="ir.ui.view">
        <field name="name">professional.portfolio.form</field>
        <field name="model">professional.portfolio</field>
        <field name="arch" type="xml">
            <form>
                <sheet>
                    <group>
                        <field name="name"/>
                        <field name="naics_ids" widget="many2many_tags"/>
                        <field name="experience_summary"/>
                        <field name="description"/>
                    </group>
                </sheet>
            </form>
        </field>
    </record>
</odoo>
EOL

echo "Project setup complete! Directory structure created with all necessary files."
echo "Run 'tree professional_portfolio' to verify the structure."
