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

        String idRecursoParam = request.getParameter("idRecurso");
        String calificacionParam = request.getParameter("calificacion");

        Testimonio t = new Testimonio();
        t.setUsuarioId(usuarioId);
        t.setMensaje(mensaje);

        boolean ok = false;

        try {
            if (idRecursoParam != null && !idRecursoParam.isEmpty()
                    && calificacionParam != null && !calificacionParam.isEmpty()) {

                int idRecurso = Integer.parseInt(idRecursoParam);
                int calificacion = Integer.parseInt(calificacionParam);

                t.setIdRecurso(idRecurso);
                t.setCalificacion(calificacion);

                ok = dao.registrarConCalificacion(t);

            } else {
                ok = dao.registrar(t);
            }

            if (ok) {
                try {
                    Notificacion notificacion = new Notificacion();
                    notificacion.setUsuarioId(1);
                    notificacion.setMensaje("💬 El usuario " + usuarioNombre + " ha enviado un nuevo testimonio.");
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

        if (ok) {
            request.setAttribute("msg", "✅ Tu testimonio fue enviado y está pendiente de aprobación.");
        } else {
            request.setAttribute("msg", "❌ Error al enviar el testimonio.");
        }

        request.getRequestDispatcher("perfilUsuario.jsp").forward(request, response);
    }

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

                if ("admin".equalsIgnoreCase(rol)) {
                    request.getRequestDispatcher("testimonios.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("testimonio.jsp").forward(request, response);
                }
                break;

            case "aprobar":
                if (!"admin".equalsIgnoreCase(rol)) { response.sendRedirect("perfilUsuario.jsp"); return; }
                int idA = Integer.parseInt(request.getParameter("id"));
                dao.cambiarEstado(idA, "Aprobado");
                response.sendRedirect("TestimonioServlet?action=listar");
                break;

            case "rechazar":
                if (!"admin".equalsIgnoreCase(rol)) { response.sendRedirect("perfilUsuario.jsp"); return; }
                int idR = Integer.parseInt(request.getParameter("id"));
                dao.cambiarEstado(idR, "Rechazado");
                response.sendRedirect("TestimonioServlet?action=listar");
                break;

            case "eliminar":
                if (!"admin".equalsIgnoreCase(rol)) { response.sendRedirect("perfilUsuario.jsp"); return; }
                int idE = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(idE);
                response.sendRedirect("TestimonioServlet?action=listar");
                break;
        }
    }
}
