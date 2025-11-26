package com.reservas;

import java.io.*;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/BannerServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class BannerServlet extends HttpServlet {

    private BannerDAO dao = new BannerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {

            case "listar":
                List<Banner> lista = dao.listar();
                request.setAttribute("banners", lista);
                request.getRequestDispatcher("banners.jsp").forward(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(idEliminar);
                response.sendRedirect("BannerServlet?accion=listar");
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Banner b = dao.buscarPorId(idEditar);

                List<Banner> listaBanners = dao.listar();

                request.setAttribute("banner", b);
                request.setAttribute("banners", listaBanners);

                request.getRequestDispatcher("banners.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String id = request.getParameter("id");
        String titulo = request.getParameter("titulo");
        boolean activo = "on".equals(request.getParameter("activo"));
        String imagenAnterior = request.getParameter("imagenAnterior");

        Part filePart = request.getPart("imagen");
        String imagenUrl = imagenAnterior; // por defecto se conserva la anterior

        // ✅ Si el usuario sube una nueva imagen → súbela a GitHub
        if (filePart != null && filePart.getSize() > 0) {
            try {
                imagenUrl = GitHubUploader.subirImagen(filePart);  
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("mensaje", "❌ Error subiendo la imagen a GitHub");
                request.getRequestDispatcher("banners.jsp").forward(request, response);
                return;
            }
        }

        // Crear objeto Banner
        Banner b = new Banner();
        b.setTitulo(titulo);
        b.setActivo(activo);
        b.setImagen(imagenUrl); // 🔥 ahora guarda la URL completa de GitHub

        boolean ok;

        if (id == null || id.isEmpty()) {
            ok = dao.registrar(b);
        } else {
            b.setId(Integer.parseInt(id));
            ok = dao.actualizar(b);
        }

        if (ok) {
            response.sendRedirect("BannerServlet?accion=listar");
        } else {
            request.setAttribute("mensaje", "❌ Error al guardar el banner en la BD");
            request.getRequestDispatcher("banners.jsp").forward(request, response);
        }

        System.out.println("==== BannerServlet POST ====");
        System.out.println("Título: " + titulo);
        System.out.println("Activo: " + activo);
        System.out.println("Imagen final guardada: " + imagenUrl);
    }
}
