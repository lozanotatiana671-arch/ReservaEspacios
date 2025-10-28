package com.reservas;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ConsultarDisponibilidadServlet")
public class ConsultarDisponibilidadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fecha = request.getParameter("fecha");
        String horaInicio = request.getParameter("horaInicio");
        String horaFin = request.getParameter("horaFin");

        response.setContentType("application/json;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            // ⚠️ Validar campos vacíos
            if (fecha == null || fecha.isEmpty() ||
                horaInicio == null || horaInicio.isEmpty() ||
                horaFin == null || horaFin.isEmpty()) {
                out.print("[]");
                return;
            }

            // ✅ Consultar recursos disponibles para la fecha/hora indicada
            List<Recurso> recursos = RecursoDAO.listarDisponibles(fecha, horaInicio);

            StringBuilder json = new StringBuilder("[");
            boolean hayResultados = false;

            for (int i = 0; i < recursos.size(); i++) {
                Recurso r = recursos.get(i);
                String estado = (r.getEstado() != null) ? r.getEstado().toUpperCase() : "DISPONIBLE";
                String mensaje;

                // 🧩 Validar estado real del recurso
                if (estado.equals("PENDIENTE") || estado.equals("APROBADA") || estado.equals("PRESTADO")) {
                    mensaje = "🚫 El recurso no se encuentra disponible para reserva.";
                } else if (estado.equals("EN_MANTENIMIENTO")) {
                    mensaje = "⚠️ El recurso está actualmente en mantenimiento.";
                } else if (estado.equals("NO_DISPONIBLE")) {
                    mensaje = "❌ El recurso está fuera de servicio temporalmente.";
                } else {
                    mensaje = "✅ Disponible para reservar entre " + horaInicio + " y " + horaFin + ".";
                }

                // 🧩 Construir objeto JSON
                json.append("{")
                    .append("\"id\":").append(r.getId()).append(",")
                    .append("\"nombre\":\"").append(r.getNombre()).append("\",")
                    .append("\"tipo\":\"").append(r.getTipo()).append("\",")
                    .append("\"estado\":\"").append(estado).append("\",")
                    .append("\"horaInicio\":\"").append(horaInicio).append("\",")
                    .append("\"horaFin\":\"").append(horaFin).append("\",")
                    .append("\"mensaje\":\"").append(mensaje).append("\"")
                    .append("}");
                if (i < recursos.size() - 1) json.append(",");
                hayResultados = true;
            }

            json.append("]");

            // ✅ Si no hay resultados, devolver mensaje genérico
            if (!hayResultados) {
                json.setLength(0);
                json.append("[{\"nombre\":\"General\",\"estado\":\"DISPONIBLE\",\"horaInicio\":\"")
                    .append(horaInicio).append("\",\"horaFin\":\"").append(horaFin)
                    .append("\",\"mensaje\":\"✅ No hay reservas registradas en ese horario.\"}]");
            }

            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error al consultar disponibilidad", e);
        }
    }
}
