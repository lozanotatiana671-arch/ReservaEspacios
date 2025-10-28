package com.reservas;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/InsertarRecursoServlet")
@MultipartConfig // ✅ Necesario para manejar archivos
public class InsertarRecursoServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 🟢 Crear objeto Recurso
        Recurso r = new Recurso();
        r.setNombre(request.getParameter("nombre"));
        r.setDescripcion(request.getParameter("descripcion"));
        r.setTipo(request.getParameter("tipo"));
        r.setEstado(request.getParameter("estado"));
        r.setUbicacion(request.getParameter("ubicacion"));

        // 🟢 Capacidad (manejo seguro)
        try {
            String capacidadParam = request.getParameter("capacidad");
            if (capacidadParam != null && !capacidadParam.isEmpty()) {
                r.setCapacidad(Integer.parseInt(capacidadParam));
            } else {
                r.setCapacidad(0);
            }
        } catch (NumberFormatException e) {
            r.setCapacidad(0);
        }

        // 🟢 Tarifa
        try {
            String tarifaParam = request.getParameter("tarifa");
            if (tarifaParam != null && !tarifaParam.isEmpty()) {
                r.setTarifa(Double.parseDouble(tarifaParam));
            } else {
                r.setTarifa(0.0);
            }
        } catch (NumberFormatException e) {
            r.setTarifa(0.0);
        }

        // 🟢 Disponible (checkbox)
        r.setDisponible(request.getParameter("disponible") != null);

        // 🟢 Manejo de imagen (con Multipart)
        try {
            Part filePart = request.getPart("imagen");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                // Ruta física donde se guardará
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                // Ruta completa del archivo
                String filePath = uploadPath + File.separator + fileName;

                // Guardar archivo en disco
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                }

                // Ruta relativa para guardar en BD
                r.setImagen("uploads/" + fileName);
            } else {
                // Si no se sube imagen, se asigna una por defecto
                r.setImagen("img/default-space.jpg");
            }
        } catch (Exception ex) {
            r.setImagen("img/default-space.jpg");
        }

        // 🟢 Guardar en base de datos
        try {
            RecursoDAO.insertar(r);
            response.sendRedirect("ListaRecursosServlet?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al insertar recurso", e);
        }
    }
}
