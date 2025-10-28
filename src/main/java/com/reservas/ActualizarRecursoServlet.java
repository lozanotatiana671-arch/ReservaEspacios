package com.reservas;

import java.io.*;
import java.nio.file.*;
import java.util.UUID;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/ActualizarRecursoServlet")
@MultipartConfig // ⚡ Necesario para manejar archivos en formularios con imágenes
public class ActualizarRecursoServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Crear objeto Recurso
        Recurso r = new Recurso();

        // ✅ ID
        r.setId(Integer.parseInt(request.getParameter("id")));

        // ✅ Campos de texto
        r.setNombre(request.getParameter("nombre"));
        r.setDescripcion(request.getParameter("descripcion"));
        r.setTipo(request.getParameter("tipo"));
        r.setEstado(request.getParameter("estado"));
        r.setUbicacion(request.getParameter("ubicacion"));

        // ✅ Capacidad
        String capacidadParam = request.getParameter("capacidad");
        if (capacidadParam != null && !capacidadParam.isEmpty()) {
            r.setCapacidad(Integer.parseInt(capacidadParam));
        } else {
            r.setCapacidad(0);
        }

        // ✅ Tarifa
        String tarifaParam = request.getParameter("tarifa");
        if (tarifaParam != null && !tarifaParam.isEmpty()) {
            r.setTarifa(Double.parseDouble(tarifaParam));
        } else {
            r.setTarifa(0.0);
        }

        // ✅ Disponible (checkbox)
        r.setDisponible(request.getParameter("disponible") != null);

        // ✅ Imagen
        String imagenActual = request.getParameter("imagenActual"); // viene oculta en el form
        Part filePart = request.getPart("imagen"); // nuevo archivo (si se sube)

        if (filePart != null && filePart.getSize() > 0) {
            // Generar nombre único para evitar conflictos
            String fileName = UUID.randomUUID().toString() + "_" +
                    Paths.get(filePart.getSubmittedFileName()).getFileName();

            // Ruta absoluta de /uploads dentro del servidor
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            // Guardar el archivo físicamente
            filePart.write(uploadPath + File.separator + fileName);

            // Guardar ruta relativa para mostrar en JSP
            r.setImagen("uploads/" + fileName);
        } else {
            // Si no se sube nueva imagen, conservar la anterior
            r.setImagen(imagenActual);
        }

        // ✅ Guardar en base de datos
        try {
            RecursoDAO.actualizar(r);
            response.sendRedirect("ListaRecursosServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al actualizar recurso: " + e.getMessage(), e);
        }
    }
}
