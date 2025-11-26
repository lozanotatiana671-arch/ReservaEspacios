package com.reservas;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;
import java.util.List;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

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
                imagenUrl = subirImagenAGitHub(filePart);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("mensaje", "❌ Error subiendo la imagen a GitHub");
                // recargar lista para que no se rompa el JSP
                List<Banner> lista = dao.listar();
                request.setAttribute("banners", lista);
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
            List<Banner> lista = dao.listar();
            request.setAttribute("banners", lista);
            request.setAttribute("mensaje", "❌ Error al guardar el banner en la BD");
            request.getRequestDispatcher("banners.jsp").forward(request, response);
        }

        System.out.println("==== BannerServlet POST ====");
        System.out.println("Título: " + titulo);
        System.out.println("Activo: " + activo);
        System.out.println("Imagen final guardada: " + imagenUrl);
    }

    /**
     * Sube la imagen recibida como Part a GitHub y devuelve la URL pública (download_url).
     */
    private String subirImagenAGitHub(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            throw new IOException("No se recibió archivo para subir.");
        }

        String nombreOriginal = filePart.getSubmittedFileName();
        String nombreFinal = System.currentTimeMillis() + "_" + nombreOriginal;

        // 1. Leer bytes del archivo
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (InputStream is = filePart.getInputStream()) {
            byte[] buffer = new byte[4096];
            int read;
            while ((read = is.read(buffer)) != -1) {
                baos.write(buffer, 0, read);
            }
        }
        byte[] fileBytes = baos.toByteArray();

        // 2. Base64
        String base64Content = Base64.getEncoder().encodeToString(fileBytes);

        // 3. Datos de GitHub
        String token  = System.getenv("GITHUB_TOKEN");  // configurado en Render
        String owner  = "lozanotatiana671-arch";
        String repo   = "ReservaEspacios";
        String branch = "master";
        String folder = "imagenes";

        if (token == null || token.isEmpty()) {
            throw new IOException("No está configurada la variable de entorno GITHUB_TOKEN.");
        }

        String pathInRepo = folder + "/" + nombreFinal;
        String apiUrl = "https://api.github.com/repos/" + owner + "/" + repo + "/contents/" + pathInRepo;

        // 4. JSON para GitHub
        JsonObject jsonBody = new JsonObject();
        jsonBody.addProperty("message", "Subir imagen " + nombreFinal);
        jsonBody.addProperty("content", base64Content);
        jsonBody.addProperty("branch", branch);

        String body = new Gson().toJson(jsonBody);

        // 5. Llamar a la API
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

        int status = conn.getResponseCode();
        if (status != 201 && status != 200) {
            InputStream err = conn.getErrorStream();
            String errorText = "";
            if (err != null) {
                errorText = new String(err.readAllBytes());
            }
            throw new IOException("Error subiendo imagen a GitHub. Código: "
                    + status + " Detalle: " + errorText);
        }

        // 6. Leer respuesta OK y sacar la URL
        String jsonResponse;
        try (InputStream is = conn.getInputStream()) {
            jsonResponse = new String(is.readAllBytes());
        }

        JsonObject jsonResp = new Gson().fromJson(jsonResponse, JsonObject.class);
        JsonObject content = jsonResp.getAsJsonObject("content");

        return content.get("download_url").getAsString();
    }
}
