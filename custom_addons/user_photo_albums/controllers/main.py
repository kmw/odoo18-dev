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
