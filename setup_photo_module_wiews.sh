#!/bin/bash

# Set the root directory
ROOT_DIR="/home/kmw/PycharmProjects/photo-module"
MODULE_DIR="$ROOT_DIR/custom_addons/user_photo_albums"
VIEWS_DIR="$MODULE_DIR/views"

# Create photo album views
echo "Creating photo album views..."
cat > "$VIEWS_DIR/photo_album_views.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>
        <!-- Form View -->
        <record id="view_photo_album_form" model="ir.ui.view">
            <field name="name">photo.album.form</field>
            <field name="model">photo.album</field>
            <field name="arch" type="xml">
                <form string="Photo Album">
                    <header>
                        <button name="action_toggle_public" type="object" 
                                string="Toggle Public Access" class="oe_highlight"/>
                    </header>
                    <sheet>
                        <div class="oe_button_box" name="button_box">
                            <button name="%(action_photo_album_photos)d" type="action"
                                    class="oe_stat_button" icon="fa-picture-o">
                                <field name="photo_count" string="Photos" widget="statinfo"/>
                            </button>
                        </div>
                        <field name="cover_photo_id" widget="image" class="oe_avatar"/>
                        <div class="oe_title">
                            <h1>
                                <field name="name" placeholder="Album Name"/>
                            </h1>
                        </div>
                        <group>
                            <group>
                                <field name="user_id"/>
                                <field name="date_created"/>
                            </group>
                            <group>
                                <field name="is_public"/>
                                <field name="active"/>
                            </group>
                        </group>
                        <notebook>
                            <page string="Description">
                                <field name="description" placeholder="Album Description..."/>
                            </page>
                            <page string="Photos">
                                <field name="photo_ids" context="{'default_album_id': active_id}">
                                    <kanban>
                                        <field name="id"/>
                                        <field name="name"/>
                                        <field name="image_small"/>
                                        <templates>
                                            <t t-name="kanban-box">
                                                <div class="oe_kanban_global_click">
                                                    <div class="o_kanban_image">
                                                        <img t-att-src="kanban_image('photo.photo', 'image_small', record.id.raw_value)"
                                                             alt="Photo"/>
                                                    </div>
                                                    <div class="oe_kanban_details">
                                                        <strong class="o_kanban_record_title">
                                                            <field name="name"/>
                                                        </strong>
                                                    </div>
                                                </div>
                                            </t>
                                        </templates>
                                    </kanban>
                                </field>
                            </page>
                        </notebook>
                    </sheet>
                    <div class="oe_chatter">
                        <field name="message_follower_ids"/>
                        <field name="message_ids"/>
                    </div>
                </form>
            </field>
        </record>

        <!-- Tree View -->
        <record id="view_photo_album_tree" model="ir.ui.view">
            <field name="name">photo.album.tree</field>
            <field name="model">photo.album</field>
            <field name="arch" type="xml">
                <tree string="Photo Albums">
                    <field name="name"/>
                    <field name="user_id"/>
                    <field name="date_created"/>
                    <field name="photo_count"/>
                    <field name="is_public"/>
                </tree>
            </field>
        </record>

        <!-- Search View -->
        <record id="view_photo_album_search" model="ir.ui.view">
            <field name="name">photo.album.search</field>
            <field name="model">photo.album</field>
            <field name="arch" type="xml">
                <search string="Search Albums">
                    <field name="name"/>
                    <field name="user_id"/>
                    <filter string="My Albums" name="my_albums" domain="[('user_id', '=', uid)]"/>
                    <filter string="Public Albums" name="public_albums" domain="[('is_public', '=', True)]"/>
                    <group expand="0" string="Group By">
                        <filter string="Created By" name="created_by" context="{'group_by': 'user_id'}"/>
                        <filter string="Created On" name="created_on" context="{'group_by': 'date_created:month'}"/>
                    </group>
                </search>
            </field>
        </record>

        <!-- Action -->
        <record id="action_photo_albums" model="ir.actions.act_window">
            <field name="name">Photo Albums</field>
            <field name="res_model">photo.album</field>
            <field name="view_mode">tree,form</field>
            <field name="context">{'search_default_my_albums': 1}</field>
            <field name="help" type="html">
                <p class="o_view_nocontent_smiling_face">
                    Create your first photo album
                </p>
            </field>
        </record>

        <!-- Menu Items -->
        <menuitem id="menu_photo_albums_root"
                  name="Photo Albums"
                  sequence="90"/>

        <menuitem id="menu_photo_albums"
                  parent="menu_photo_albums_root"
                  action="action_photo_albums"
                  sequence="10"/>
    </data>
</odoo>
EOF

# Create photo views
echo "Creating photo views..."
cat > "$VIEWS_DIR/photo_views.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>
        <!-- Form View -->
        <record id="view_photo_form" model="ir.ui.view">
            <field name="name">photo.photo.form</field>
            <field name="model">photo.photo</field>
            <field name="arch" type="xml">
                <form string="Photo">
                    <sheet>
                        <field name="image" widget="image" class="oe_avatar"/>
                        <div class="oe_title">
                            <h1>
                                <field name="name" placeholder="Photo Title"/>
                            </h1>
                        </div>
                        <group>
                            <group>
                                <field name="album_id"/>
                                <field name="user_id"/>
                                <field name="date_uploaded"/>
                            </group>
                            <group>
                                <field name="category_ids" widget="many2many_tags"/>
                                <field name="tag_ids" widget="many2many_tags"/>
                                <field name="view_count"/>
                            </group>
                        </group>
                        <notebook>
                            <page string="Description">
                                <field name="description" placeholder="Photo Description..."/>
                            </page>
                        </notebook>
                    </sheet>
                    <div class="oe_chatter">
                        <field name="message_follower_ids"/>
                        <field name="message_ids"/>
                    </div>
                </form>
            </field>
        </record>

        <!-- Tree View -->
        <record id="view_photo_tree" model="ir.ui.view">
            <field name="name">photo.photo.tree</field>
            <field name="model">photo.photo</field>
            <field name="arch" type="xml">
                <tree string="Photos">
                    <field name="name"/>
                    <field name="album_id"/>
                    <field name="user_id"/>
                    <field name="date_uploaded"/>
                    <field name="view_count"/>
                </tree>
            </field>
        </record>

        <!-- Kanban View -->
        <record id="view_photo_kanban" model="ir.ui.view">
            <field name="name">photo.photo.kanban</field>
            <field name="model">photo.photo</field>
            <field name="arch" type="xml">
                <kanban>
                    <field name="id"/>
                    <field name="name"/>
                    <field name="image_small"/>
                    <templates>
                        <t t-name="kanban-box">
                            <div class="oe_kanban_global_click">
                                <div class="o_kanban_image">
                                    <img t-att-src="kanban_image('photo.photo', 'image_small', record.id.raw_value)"
                                         alt="Photo"/>
                                </div>
                                <div class="oe_kanban_details">
                                    <strong class="o_kanban_record_title">
                                        <field name="name"/>
                                    </strong>
                                    <div>In: <field name="album_id"/></div>
                                </div>
                            </div>
                        </t>
                    </templates>
                </kanban>
            </field>
        </record>

        <!-- Search View -->
        <record id="view_photo_search" model="ir.ui.view">
            <field name="name">photo.photo.search</field>
            <field name="model">photo.photo</field>
            <field name="arch" type="xml">
                <search string="Search Photos">
                    <field name="name"/>
                    <field name="album_id"/>
                    <field name="user_id"/>
                    <field name="category_ids"/>
                    <field name="tag_ids"/>
                    <filter string="My Photos" name="my_photos" domain="[('user_id', '=', uid)]"/>
                    <group expand="0" string="Group By">
                        <filter string="Album" name="group_album" context="{'group_by': 'album_id'}"/>
                        <filter string="Upload Date" name="group_date" context="{'group_by': 'date_uploaded:month'}"/>
                    </group>
                </search>
            </field>
        </record>

        <!-- Action -->
        <record id="action_photos" model="ir.actions.act_window">
            <field name="name">Photos</field>
            <field name="res_model">photo.photo</field>
            <field name="view_mode">kanban,tree,form</field>
            <field name="context">{'search_default_my_photos': 1}</field>
        </record>

        <!-- Menu Item -->
        <menuitem id="menu_photos"
                  parent="menu_photo_albums_root"
                  action="action_photos"
                  sequence="20"/>
    </data>
</odoo>
EOF

# Create category views
echo "Creating category views..."
cat > "$VIEWS_DIR/photo_category_views.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>
        <!-- Form View -->
        <record id="view_photo_category_form" model="ir.ui.view">
            <field name="name">photo.category.form</field>
            <field name="model">photo.category</field>
            <field name="arch" type="xml">
                <form string="Photo Category">
                    <sheet>
                        <group>
                            <group>
                                <field name="name"/>
                                <field name="parent_id"/>
                            </group>
                            <group>
                                <field name="active"/>
                            </group>
                        </group>
                        <notebook>
                            <page string="Description">
                                <field name="description"/>
                            </page>
                            <page string="Child Categories">
                                <field name="child_ids"/>
                            </page>
                            <page string="Photos">
                                <field name="photo_ids"/>
                            </page>
                        </notebook>
                    </sheet>
                </form>
            </field>
        </record>

        <!-- Tree View -->
        <record id="view_photo_category_tree" model="ir.ui.view">
            <field name="name">photo.category.tree</field>
            <field name="model">photo.category</field>
            <field name="arch" type="xml">
                <tree string="Photo Categories">
                    <field name="name"/>
                    <field name="parent_id"/>
                </tree>
            </field>
        </record>

        <!-- Action -->
        <record id="action_photo_categories" model="ir.actions.act_window">
            <field name="name">Categories</field>
            <field name="res_model">photo.category</field>
            <field name="view_mode">tree,form</field>
        </record>

        <!-- Menu Item -->
        <menuitem id="menu_photo_categories"
                  parent="menu_photo_albums_root"
                  action="action_photo_categories"
                  sequence="30"/>
    </data>
</odoo>
EOF

# Create website templates
echo "Creating website templates..."
cat > "$VIEWS_DIR/templates.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>
        <template id="portal_my_albums" name="My Photo Albums">
            <t t-call="portal.portal_layout">
                <div class="container">
                    <h3>My Photo Albums</h3>
                    <div class="row mt16">
                        <t t-foreach="albums" t-as="album">
                            <div class="col-md-4 mb16">
                                <div class="card">
                                    <div t-if="album.cover_photo_id" class="card-img-top">
                                        <img t-att-src="'/web/image/photo.photo/%s/image_medium' % album.cover_photo_id.id"
                                             class="img-fluid" alt="Album Cover"/>
                                    </div>
                                    <div class="card-body">
                                        <h5 class="card-title">
                                            <t t-esc="album.name"/>
                                        </h5>
                                        <p class="card-text">
                                            <small class="text-muted">
                                                Photos: <t t-esc="album.photo_count"/>
                                            </small>
                                        </p>
                                        <a t-att-href="'/my/albums/%s' % album.id"
                                           class="btn btn-primary">View Album</a>
                                    </div>
                                </div>
                            </div>
                        </t>
                    </div>
                </div>
            </t>
        </template>

        <template id="portal_my_album" name="Album">
            <t t-call="portal.portal_layout">
                <div class="container">
                    <h3><t t-esc="album.name"/></h3>
                    <div class="row mt16">
                        <t t-foreach="album.photo_ids" t-as="photo">
