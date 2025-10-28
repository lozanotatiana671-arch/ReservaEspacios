<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.reservas.Recurso, com.reservas.RecursoDAO, java.util.*" %>

<%
    // ✅ Validar sesión de usuario
    HttpSession sesion = request.getSession(false);
    boolean usuarioLogueado = (sesion != null && sesion.getAttribute("usuarioId") != null);
    
    String recursoIdParam = request.getParameter("recursoId");
    int recursoId = (recursoIdParam != null) ? Integer.parseInt(recursoIdParam) : 1;

    Recurso recurso = null;

    try {
        for (Recurso r : RecursoDAO.listar()) {
            if (r.getId() == recursoId) {
                recurso = r;
                break;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (recurso == null) {
        recurso = new Recurso();
        recurso.setNombre("Recurso no encontrado");
        recurso.setDescripcion("No hay información disponible para este recurso.");
        recurso.setTipo("N/A");
        recurso.setTarifa(0);
        recurso.setImagen("img/noimage.jpg");
        recurso.setCapacidad(0);
        
    }
    
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= recurso.getNombre() %> - ReservaEspacios</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/tuespacio.css">
</head>
<body>
    <% if (request.getAttribute("mensaje") != null) { %>
    <div class="alert alert-info text-center" style="margin: 20px;">
        <%= request.getAttribute("mensaje") %>
    </div>
<% } %>



<!-- 🔹 Navbar -->
<%
    if (usuarioLogueado) {
%>
    <%@ include file="navbarPrivado.jsp" %>
<% } else { %>
    <%@ include file="navbarPublico.jsp" %>
<% } %>

    <!-- Imagen del espacio -->
    <div class="space-image-container">
        <img src="<%= recurso.getImagen() != null ? recurso.getImagen() : "img/noimage.jpg" %>" 
             alt="Imagen del espacio" class="space-image">
    </div>

    <!-- Barra de información -->
    <div class="space-info-bar">
        <span><%= recurso.getNombre().toUpperCase() %></span>
        <span>$<%= String.format("%,.0f", recurso.getTarifa()) %> / Hora</span>
    </div>

    <!-- Contenido principal -->
    <div class="container">
        <!-- Columna izquierda -->
        <div class="left-column">
            <div class="space-icons">
                <div class="icon-item">
                    <i class="fas fa-layer-group"></i>
                    <span class="icon-label"><%= recurso.getTipo() %></span>
                </div>
                <div class="icon-item">
                    <i class="far fa-calendar"></i>
                    <span class="icon-label"><%= java.time.Year.now() %></span>
                </div>
                <div class="icon-item">
                    <i class="fas fa-user-friends"></i>
                    <span class="icon-label"><%= recurso.getCapacidad() %> personas</span>
                </div>
            </div>

            <!-- Tabs -->
            <div class="tabs">
                <div class="tab active" data-tab="description">Descripción</div>
                <div class="tab" data-tab="accessories">Accesorios</div>
            </div>

            <!-- Contenido de pestañas -->
            <div class="tab-content">
                <div class="tab-pane active" id="description">
                    <p><%= recurso.getDescripcion() %></p>
                    <p style="margin-top: 1rem; color: var(--text-secondary);">
                        ID del recurso seleccionado: <strong><%= recurso.getId() %></strong>
                    </p>
                </div>

                <!-- ✅ Check list interactivo -->
                <div class="tab-pane" id="accessories">
                    <div class="checklist">
                        <div class="check-item" onclick="toggleCheck(this)">
                            <div class="check-icon yes">✓</div>
                            <span>Sillas</span>
                        </div>
                        <div class="check-item" onclick="toggleCheck(this)">
                            <div class="check-icon yes">✓</div>
                            <span>Micrófono</span>
                        </div>
                        <div class="check-item" onclick="toggleCheck(this)">
                            <div class="check-icon yes">✓</div>
                            <span>WiFi</span>
                        </div>
                        <div class="check-item" onclick="toggleCheck(this)">
                            <div class="check-icon yes">✓</div>
                            <span>Pantalla</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Columna derecha -->
        <div class="right-column">
            <h3 class="titulo-reserva">Reservar ahora</h3>
           <form method="post" action="ReservaServlet">
<form method="post" action="ReservaServlet">
  <input type="hidden" name="recursoId" value="<%= recurso.getId() %>">

  <div class="form-group">
    <label class="form-label">Fecha</label>
    <input type="date" name="fecha" id="fecha" class="form-input" required>
  </div>

  <div class="form-group">
    <label class="form-label">Hora de inicio</label>
    <input type="time" name="horaInicio" id="horaInicio" class="form-input" required>
  </div>

  <div class="form-group">
    <label class="form-label">Hora de fin</label>
    <input type="time" name="horaFin" id="horaFin" class="form-input" required>
  </div>

  <button type="submit" class="btn-reserve">Haz tu reserva</button>
</form>


        </div>
    </div>

                
<script>
  // ✅ Consulta de disponibilidad en tiempo real
  async function consultarDisponibilidad() {
    const fecha = document.getElementById('fecha').value;
    const hora = document.getElementById('hora').value;
    const contenedor = document.getElementById('disponibilidad-container');

    if (!fecha || !hora) {
      contenedor.innerHTML = '';
      return;
    }

    try {
      const response = await fetch(`ConsultarDisponibilidadServlet?fecha=${fecha}&hora=${hora}`);
      const data = await response.json();

      if (data.length === 0) {
        contenedor.innerHTML = "<p class='text-danger'>❌ No hay espacios disponibles en ese horario.</p>";
        return;
      }

      let html = "<h6 class='text-success'>✔ Espacios disponibles:</h6>";
      data.forEach(r => {
        const color = (r.estado === 'DISPONIBLE') ? 'green' :
                      (r.estado === 'EN_MANTENIMIENTO') ? 'orange' : 'red';
        html += `<div style="border-left:4px solid ${color}; padding:5px; margin-bottom:3px;">
                   <strong>${r.nombre}</strong> - ${r.mensaje}
                 </div>`;
      });

      contenedor.innerHTML = html;

    } catch (error) {
      contenedor.innerHTML = "<p class='text-warning'>⚠ Error al consultar disponibilidad.</p>";
    }
  }
</script>


    <footer class="footer">
        © 2025 ReservaEspacios - Todos los derechos reservados
    </footer>

    <script>
        // Control de pestañas
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', function() {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
                this.classList.add('active');
                const tabId = this.getAttribute('data-tab');
                document.getElementById(tabId).classList.add('active');
            });
        });

        // Check interactivo
        function toggleCheck(element) {
            const icon = element.querySelector('.check-icon');
            if (icon.classList.contains('yes')) {
                icon.classList.remove('yes');
                icon.classList.add('no');
                icon.textContent = '×';
            } else {
                icon.classList.remove('no');
                icon.classList.add('yes');
                icon.textContent = '✓';
            }
        }
    </script>
</body>
</html>
