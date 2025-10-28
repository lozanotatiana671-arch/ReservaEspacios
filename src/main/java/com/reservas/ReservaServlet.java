package com.reservas;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class ReservaServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReservaServlet.class.getName());
    private ReservaDAO reservaDAO = new ReservaDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        String mensaje;

        // 🧩 Validar sesión activa
        if (sesion == null || sesion.getAttribute("usuarioId") == null) {
            mensaje = "❌ Sesión expirada. Por favor, inicie sesión nuevamente.";
        } else {
            Integer usuarioId = (Integer) sesion.getAttribute("usuarioId");
            String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");

            // 🔹 Capturar los parámetros del formulario
            String fecha = request.getParameter("fecha");
            String horaInicio = request.getParameter("horaInicio");
            String horaFin = request.getParameter("horaFin");
            String recursoIdStr = request.getParameter("recursoId");

            // 🔹 Validar campos vacíos
            if (recursoIdStr == null || recursoIdStr.isEmpty()) {
                mensaje = "⚠️ No se ha seleccionado ningún espacio.";
            } 
            else if (fecha == null || fecha.isEmpty() || 
                     horaInicio == null || horaInicio.isEmpty() || 
                     horaFin == null || horaFin.isEmpty()) {
                mensaje = "⚠️ Por favor selecciona una fecha y ambas horas antes de hacer la reserva.";
            } 
            else {
                try {
                    int recursoId = Integer.parseInt(recursoIdStr);
                    java.sql.Date fechaSQL = java.sql.Date.valueOf(fecha);

                    // 🔹 Validar que la hora de fin sea posterior a la hora de inicio
                    if (horaFin.compareTo(horaInicio) <= 0) {
                        mensaje = "⚠️ La hora de fin debe ser posterior a la hora de inicio.";
                    } else {
                        // 🔹 Validar conflictos de horarios
                        boolean conflicto = reservaDAO.hayConflicto(recursoId, fechaSQL, horaInicio, horaFin);

                        if (conflicto) {
                            mensaje = "⚠️ El recurso ya está reservado en ese rango de horario.";
                        } else {
                            // ✅ Crear objeto reserva
                            Reserva r = new Reserva();
                            r.setNombre(usuarioNombre);
                            r.setFecha(fecha);
                            r.setHoraInicio(horaInicio);
                            r.setHoraFin(horaFin);
                            r.setEstado("Pendiente");
                            r.setUsuarioId(usuarioId);
                            r.setRecursoId(recursoId);

                            // ✅ Guardar reserva
                            if (reservaDAO.guardarConRango(r)) {
                                mensaje = "✅ Reserva guardada para " + usuarioNombre +
                                          " el " + fecha + " de " + horaInicio + " a " + horaFin + ".";

                                // 🔔 NOTIFICACIÓN AL ADMINISTRADOR
                                try {
                                    Notificacion notificacion = new Notificacion();
                                    notificacion.setUsuarioId(1); // 🧑‍💼 ID del administrador
                                    notificacion.setReservaId(r.getId()); // Si se genera el ID en BD
                                    notificacion.setMensaje("🆕 Nueva solicitud de reserva de " + usuarioNombre +
                                        " para el recurso #" + recursoId + " el " + fecha + ".");
                                    notificacion.setEstado("NUEVA");
                                    new NotificacionDAO().insertar(notificacion);
                                } catch (Exception ex) {
                                    LOGGER.log(Level.WARNING, "No se pudo registrar la notificación al admin", ex);
                                }

                            } else {
                                mensaje = "❌ Error al guardar la reserva.";
                            }
                        }
                    }

                } catch (NumberFormatException e) {
                    mensaje = "❌ ID de recurso inválido.";
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Error en reserva", e);
                    mensaje = "❌ Error interno al procesar la reserva.";
                }
            }
        }

        // 🧩 Retornar mensaje en la misma vista
        request.setAttribute("mensaje", mensaje);
        request.getRequestDispatcher("detalleEspacio.jsp").forward(request, response);
    }
}
