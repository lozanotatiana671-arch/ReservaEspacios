package com.reservas;

import java.io.IOException;
import java.sql.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DisponibilidadServlet")
public class DisponibilidadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Usamos tu DAO existente
    private final ReservaDAO reservaDAO = new ReservaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Siempre respondemos JSON
        response.setContentType("application/json; charset=UTF-8");

        try {
            // 🔹 Leer parámetros
            String recursoIdStr = request.getParameter("recursoId");
            String fechaStr     = request.getParameter("fecha");
            String horaInicio   = request.getParameter("horaInicio");
            String horaFin      = request.getParameter("horaFin");

            // Validaciones básicas
            if (recursoIdStr == null || recursoIdStr.isEmpty() ||
                fechaStr == null     || fechaStr.isEmpty()     ||
                horaInicio == null   || horaInicio.isEmpty()   ||
                horaFin == null      || horaFin.isEmpty()) {

                // Si falta algo, devolvemos no disponible
                response.getWriter().write("{\"disponible\":false}");
                return;
            }

            int recursoId = Integer.parseInt(recursoIdStr);
            Date fecha    = Date.valueOf(fechaStr);

            // 🔹 Usamos tu lógica existente para detectar conflicto
            boolean hayConflicto = reservaDAO.hayConflicto(recursoId, fecha, horaInicio, horaFin);

            // Si hay conflicto → NO disponible
            boolean disponible = !hayConflicto;

            // 🔹 Respuesta JSON simple para el frontend
            String json = "{\"disponible\":" + disponible + "}";
            response.getWriter().write(json);

        } catch (Exception e) {
            // En caso de error, por seguridad respondemos como NO disponible
            e.printStackTrace();
            response.getWriter().write("{\"disponible\":false}");
        }
    }

    // Si alguien llama por POST, reutilizamos la misma lógica
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
