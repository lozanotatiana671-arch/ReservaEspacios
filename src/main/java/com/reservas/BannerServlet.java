package com.reservas;

import java.io.*;
import java.nio.file.Paths;
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
    private static final String UPLOAD_DIR = "uploads";

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

    // 🔹 Volver a cargar la lista completa para mostrarla en el JSP
    List<Banner> listaBanners = dao.listar();

    // 🔹 Enviar tanto el banner seleccionado como la lista completa
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

        // 📂 Guardar archivo en carpeta uploads/
        Part filePart = request.getPart("imagen");
        String fileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            filePart.write(uploadPath + File.separator + fileName);
        }

        Banner b = new Banner();
        b.setTitulo(titulo);
        b.setActivo(activo);

        if (fileName != null) {
            b.setImagen(fileName);
        } else {
            b.setImagen(request.getParameter("imagenAnterior"));
        }

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
            request.setAttribute("mensaje", "Error al guardar el banner, revisar consola");
            request.getRequestDispatcher("banners.jsp").forward(request, response);
        }

        // 🔍 Log de depuración
        System.out.println("==== BannerServlet POST ====");
        System.out.println("Título: " + titulo);
        System.out.println("Activo: " + activo);
        System.out.println("Archivo enviado: " + (filePart != null ? filePart.getSubmittedFileName() : "null"));
    }
}
