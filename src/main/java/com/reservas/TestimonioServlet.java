package com.reservas;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/TestimonioServlet")
public class TestimonioServlet extends HttpServlet {

    private TestimonioDAO dao = new TestimonioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int usuarioId = (int) sesion.getAttribute("usuarioId");
        String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");
        String mensaje = request.getParameter("mensaje");

        String recursoIdParam = request.getParameter("recursoId");
        String calificacionParam = request.getParameter("calificacion");

        // 🟢 Debug
        System.out.println("🟢 Usuario ID: " + usuarioId);
        System.out.println("📦 Recurso ID: " + recursoIdParam);
        System.out.println("💬 Mensaje: " + mensaje);
        System.out.println("⭐ Calificación: " + calificacionParam);

        Testimonio t = new Testimonio();
        t.setUsuarioId(usuarioId);
        t.setMensaje(mensaje);

        boolean ok = false;

        try {
            // 🔹 Testimonio con calificación y recurso
            if (recursoIdParam != null && !recursoIdParam.isEmpty()
                    && calificacionParam != null && !calificacionParam.isEmpty()) {

                int recursoId = Integer.parseInt(recursoIdParam);
                int calificacion = Integer.parseInt(calificacionParam);

                t.setRecursoId(recursoId);
                t.setCalificacion(calificacion);

                ok = dao.registrarConCalificacion(t);
            } else {
                // 🔹 Testimonio sin calificación
                ok = dao.registrar(t);
            }

            // ********************************************
            // 🔔 NOTIFICACIÓN SOLO PARA EL USUARIO (CORREGIDO)
            // ********************************************
            if (ok) {
                try {
                    Notificacion notificacion = new Notificacion();
                    notificacion.setUsuarioId(usuarioId); // AHORA SÍ → para el usuario
                    notificacion.setMensaje("💬 Tu testimonio fue enviado correctamente.");
                    notificacion.setEstado("NUEVA");

                    new NotificacionDAO().insertar(notificacion);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            ok = false;
        }

        // Mensaje visual al usuario
        if (ok) {
            System.out.println("✅ Testimonio guardado correctamente por usuario " + usuarioNombre);
            request.setAttribute("msg", "✅ Tu testimonio fue enviado y está pendiente de aprobación.");
        } else {
            System.err.println("❌ Error al guardar el testimonio de " + usuarioNombre);
            request.setAttribute("msg", "❌ Error al enviar el testimonio. Intenta nuevamente.");
        }

        request.getRequestDispatcher("perfilUsuario.jsp").forward(request, response);
    }

    // ============================================================
    // 🔹 GET: listar, aprobar, rechazar y eliminar testimonios
    // ============================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String rol = (String) sesion.getAttribute("usuarioRol");
        String action = request.getParameter("action");
        if (action == null) action = "listar";

        switch (action) {

            case "listar":
                List<Testimonio> lista = dao.listar();
                request.setAttribute("testimonios", lista);

                if ("ADMIN".equalsIgnoreCase(rol)) {
                    request.getRequestDispatcher("testimonios.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("testimonio.jsp").forward(request, response);
                }
                break;

            case "aprobar":
                if (!"ADMIN".equalsIgnoreCase(rol)) {
                    response.sendRedirect("perfilUsuario.jsp");
                    return;
                }
                int idA = Integer.parseInt(request.getParameter("id"));
                dao.cambiarEstado(idA, "Aprobado");
                response.sendRedirect("TestimonioServlet?action=listar");
                break;

            case "rechazar":
                if (!"ADMIN".equalsIgnoreCase(rol)) {
                    response.sendRedirect("perfilUsuario.jsp");
                    return;
                }
                int idR = Integer.parseInt(request.getParameter("id"));
                dao.cambiarEstado(idR, "Rechazado");
                response.sendRedirect("TestimonioServlet?action=listar");
                break;

            case "eliminar":
                if (!"ADMIN".equalsIgnoreCase(rol)) {
                    response.sendRedirect("perfilUsuario.jsp");
                    return;
                }
                int idE = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(idE);
                response.sendRedirect("TestimonioServlet?action=listar");
                break;
        }
    }
}
