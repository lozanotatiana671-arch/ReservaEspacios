<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession, java.util.*, com.reservas.*" %>
<%
    // 🔹 Verificar sesión
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int usuarioId = (int) sesion.getAttribute("usuarioId");
    String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");

    // 🔹 Cargar reservas y filtrar por usuario
    ReservaDAO reservaDAO = new ReservaDAO();
    RecursoDAO recursoDAO = new RecursoDAO();
    List<Reserva> todas = reservaDAO.listar();
    List<Recurso> recursos = recursoDAO.listar();
    List<Reserva> reservas = new ArrayList<>();

    for (Reserva r : todas) {
        if (r.getUsuarioId() == usuarioId) reservas.add(r);
    }

    // 🔹 Cargar notificaciones desde el filtro
    List<Notificacion> notificaciones = (List<Notificacion>) request.getAttribute("notificaciones");
    if (notificaciones == null) notificaciones = new ArrayList<>();
    Integer notificacionesCount = (Integer) request.getAttribute("notificacionesCount");
    if (notificacionesCount == null) notificacionesCount = notificaciones.size();

    // ===== PAGINACIÓN RESERVAS =====
    int pageRes = request.getParameter("pageRes") != null ? Integer.parseInt(request.getParameter("pageRes")) : 1;
    int perPageRes = 1; // Mostrar solo una reserva por página
    int totalRes = reservas.size();
    int totalPagesRes = (int) Math.ceil((double) totalRes / perPageRes);
    int startRes = (pageRes - 1) * perPageRes;
    int endRes = Math.min(startRes + perPageRes, totalRes);
%>

<%!
    // 🔹 Método auxiliar para obtener el recurso asociado
    public Recurso getRecursoPorId(int id, List<Recurso> lista) {
        for (Recurso rec : lista) {
            if (rec.getId() == id) return rec;
        }
        return null;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Dashboard - ReservaEspacios</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Estilos personalizados -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfilUsuario.css">
</head>

<body>
  <!-- 🔹 Sidebar -->
<div class="sidebar">
  <a class="navbar-brand" href="index.jsp">ReservaEspacios</a>
  <ul class="nav flex-column mt-4">

    <!-- Dashboard -->
    <li class="nav-item">
      <a class="nav-link" href="perfilUsuario.jsp">
        <i class="fas fa-tachometer-alt"></i>
        <span>Dashboard</span>
      </a>
    </li>

    <!-- Mis Reservas -->
    <li class="nav-item">
      <a class="nav-link" href="MisReservasServlet">
        <i class="fas fa-calendar-check"></i>
        <span>Mis Reservas</span>
      </a>
    </li>

    <!-- Mis Testimonios -->
    <li class="nav-item">
      <a class="nav-link" href="misTestimonios.jsp">
        <i class="fas fa-comment-dots"></i>
        <span>Mis Testimonios</span>
      </a>
    </li>

    <!-- Notificaciones -->
    <li class="nav-item">
      <a class="nav-link" href="notificaciones.jsp">
        <i class="fas fa-bell"></i>
        <span>Notificaciones</span>
        <% if (notificacionesCount > 0) { %>
          <span class="badge badge-warning badge-pill ml-2"><%= notificacionesCount %></span>
        <% } %>
      </a>
    </li>

    <!-- Mi Perfil -->
    <li class="nav-item">
      <a class="nav-link" href="editarPerfil.jsp">
        <i class="fas fa-user"></i>
        <span>Mi Perfil</span>
      </a>
    </li>

    <!-- Contáctenos -->
    <li class="nav-item">
      <a class="nav-link" href="contactenos.jsp">
        <i class="fas fa-envelope"></i>
        <span>Contáctenos</span>
      </a>
    </li>
  </ul>
</div>


  <!-- 🔹 Contenido Principal -->
  <div class="content">
    <div class="header">
      <h2 class="mb-0">¡Bienvenido!</h2>
      <div class="user-info">
        <i class="fas fa-user"></i>
        <span>Bienvenido, <%= usuarioNombre %> 👋</span>
        <a href="LogoutServlet" class="btn btn-logout">Cerrar Sesión</a>
      </div>
    </div><br><br><br>

    <!-- 🔹 Contenedor de Reservas -->
    <div class="reservation-container">
      <table class="reservation-list">
        <thead>
          <tr>
            <th>Información de la Reserva</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <%
            if (reservas != null && !reservas.isEmpty()) {
                for (int i = startRes; i < endRes; i++) {
                    Reserva r = reservas.get(i);
                    Recurso recurso = getRecursoPorId(r.getRecursoId(), recursos);

                    String estado = r.getEstado();
                    String claseEstado = "status pendiente";
                    if ("Aprobada".equalsIgnoreCase(estado)) claseEstado = "status aprobado";
                    else if ("Cancelado".equalsIgnoreCase(estado)) claseEstado = "status cancelado";
                    else if ("Finalizado".equalsIgnoreCase(estado)) claseEstado = "status finalizado";
          %>

          <tr class="reservation-card">
            <td class="reservation-info">
              <h3><i class="fas fa-door-open"></i> <%= recurso != null ? recurso.getNombre() : "Recurso no encontrado" %></h3>
              <% if (recurso != null) { %>
                <p><i class="fas fa-map-marker-alt"></i> <strong>Ubicación:</strong> <%= recurso.getUbicacion() %></p>
                <p><i class="fas fa-info-circle"></i> <strong>Descripción:</strong> <%= recurso.getDescripcion() %></p>
                <p><i class="fas fa-users"></i> <strong>Capacidad:</strong> <%= recurso.getCapacidad() %> personas</p>
                <p><i class="fas fa-tag"></i> <strong>Tipo:</strong> <%= recurso.getTipo() %></p>
                <p><i class="fas fa-dollar-sign"></i> <strong>Tarifa:</strong> $<%= recurso.getTarifa() %></p>
              <% } %>
              <p><i class="fas fa-calendar"></i> <strong>Fecha:</strong> <%= r.getFecha() %></p>
              <!-- ✅ Mostrar rango de horas -->
              <p><i class="fas fa-clock"></i> <strong>Horario:</strong> <%= r.getHoraInicio() %> - <%= r.getHoraFin() %></p>
              <p><i class="fas fa-check-circle"></i> <strong>Estado:</strong>
                <span class="<%= claseEstado %>"><%= estado %></span>
              </p>
            </td>
            <td class="reservation-actions">
              <%
    String estadoReserva = r.getEstado();
    if ("APROBADA".equalsIgnoreCase(estadoReserva) ||
        "APROBADO".equalsIgnoreCase(estadoReserva) ||
        "FINALIZADA".equalsIgnoreCase(estadoReserva) ||
        "FINALIZADO".equalsIgnoreCase(estadoReserva)) {
%>
    <form action="testimonio.jsp" method="get" style="display:inline;">
    <input type="hidden" name="recursoId" value="<%= r.getRecursoId() %>">
    <button type="submit" class="action-btn btn-testimonio">
        <i class="fas fa-comment"></i> Testimonio
    </button>
</form>

<% } %>


              <!-- ❌ Botón de cancelar con JS dinámico -->
              <button type="button" class="action-btn btn-cancelar"
                      onclick="cancelarReserva(this, <%= r.getId() %>)">
                  <i class="fas fa-times"></i> Cancelar
              </button>
            </td>
          </tr>

          <% } } else { %>
            <tr><td colspan="2" class="text-center">No tienes reservas registradas.</td></tr>
          <% } %>
        </tbody>
      </table>

      <!-- 🔹 Paginación -->
      <div class="pagination text-center mt-3">
        <% if (pageRes > 1) { %>
          <a href="?pageRes=<%= pageRes - 1 %>" class="btn btn-outline-success">&lt;&lt;</a>
        <% } %>
        <span class="mx-3">Página <%= pageRes %> de <%= totalPagesRes %></span>
        <% if (pageRes < totalPagesRes) { %>
          <a href="?pageRes=<%= pageRes + 1 %>" class="btn btn-outline-success">&gt;&gt;</a>
        <% } %>
      </div>
    </div>
  </div>

  <!-- ✅ Script Cancelar Reserva con alerta visual -->
  <script>
  function cancelarReserva(boton, idReserva) {
    if (!confirm('¿Seguro que deseas cancelar esta reserva?')) return;

    fetch(`CancelarReservaServlet?id=${idReserva}`)
      .then(response => {
        if (response.ok) {
          const fila = boton.closest('.reservation-card');
          if (fila) fila.remove();

          const mensaje = document.createElement('div');
          mensaje.className = 'alert alert-success text-center';
          mensaje.style.margin = '10px 0';
          mensaje.style.fontWeight = '600';
          mensaje.textContent = '✅ Reserva cancelada exitosamente.';
          document.querySelector('.reservation-container').prepend(mensaje);

          setTimeout(() => mensaje.remove(), 3000);
        } else {
          alert('❌ Error al cancelar la reserva.');
        }
      })
      .catch(() => alert('⚠️ No se pudo contactar con el servidor.'));
  }
  </script>



  <!-- Bootstrap -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
