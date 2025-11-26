package com.reservas;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.SQLException;
import java.nio.file.Paths;
import java.util.Base64;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/InsertarRecursoServlet")
@MultipartConfig
public class InsertarRecursoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Crear objeto Recurso
        Recurso r = new Recurso();
        r.setNombre(request.getParameter("nombre"));
        r.setDescripcion(request.getParameter("descripcion"));
        r.setTipo(request.getParameter("tipo"));
        r.setEstado(request.getParameter("estado"));
        r.setUbicacion(request.getParameter("ubicacion"));

        // Capacidad
        try {
            String capacidadParam = request.getParameter("capacidad");
            r.setCapacidad(capacidadParam != null && !capacidadParam.isEmpty()
                    ? Integer.parseInt(capacidadParam)
                    : 0);
        } catch (NumberFormatException e) {
            r.setCapacidad(0);
        }

        // Tarifa
        try {
            String tarifaParam = request.getParameter("tarifa");
            r.setTarifa(tarifaParam != null && !tarifaParam.isEmpty()
                    ? Double.parseDouble(tarifaParam)
                    : 0.0);
        } catch (NumberFormatException e) {
            r.setTarifa(0.0);
        }

        // Disponible
        r.setDisponible(request.getParameter("disponible") != null);

        // 📌 SUBIR IMAGEN A GITHUB
        String imagenURL = null;
        Part filePart = request.getPart("imagen");

        if (filePart != null && filePart.getSize() > 0) {
            try {
                imagenURL = subirImagenAGitHub(filePart);
            } catch (Exception ex) {
                ex.printStackTrace();
                imagenURL = "img/default-space.jpg"; // fallback
            }
        } else {
            imagenURL = "img/default-space.jpg";
        }

        r.setImagen(imagenURL);

        // Guardar en BD
        try {
            RecursoDAO.insertar(r);
            response.sendRedirect("ListaRecursosServlet?success=true");
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("❌ Error al insertar recurso", e);
        }
    }

    /**
     * 🔵 SUBIR ARCHIVO A GITHUB Y RETORNAR download_url
     */
    private String subirImagenAGitHub(Part filePart) throws Exception {

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String finalName = System.currentTimeMillis() + "_" + fileName;

        // Leer bytes del archivo
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (InputStream is = filePart.getInputStream()) {
            byte[] buffer = new byte[4096];
            int read;
            while ((read = is.read(buffer)) != -1) {
                baos.write(buffer, 0, read);
            }
        }

        String base64 = Base64.getEncoder().encodeToString(baos.toByteArray());

        // GitHub Info
        String token = System.getenv("GITHUB_TOKEN");
        String owner = "lozanotatiana671-arch";
        String repo = "ReservaEspacios";
        String branch = "master";
        String folder = "espacios";

        if (token == null) {
            throw new Exception("Falta variable GITHUB_TOKEN");
        }

        String apiUrl =
                "https://api.github.com/repos/" + owner + "/" + repo + "/contents/" + folder + "/" + finalName;

        // Crear body JSON
        JsonObject json = new JsonObject();
        json.addProperty("message", "Nueva imagen de recurso");
        json.addProperty("content", base64);
        json.addProperty("branch", branch);

        String body = new Gson().toJson(json);

        // Llamado a GitHub
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("PUT");
        conn.setDoOutput(true);
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setRequestProperty("Accept", "application/vnd.github+json");
        conn.setRequestProperty("Content-Type", "application/json");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes());
        }

        if (conn.getResponseCode() != 201 && conn.getResponseCode() != 200) {
            throw new RuntimeException("GitHub API error: " + conn.getResponseCode());
        }

        // Leer respuesta
        String jsonResponse = new String(conn.getInputStream().readAllBytes());
        JsonObject resp = new Gson().fromJson(jsonResponse, JsonObject.class);

        return resp.getAsJsonObject("content").get("download_url").getAsString();
    }
}
