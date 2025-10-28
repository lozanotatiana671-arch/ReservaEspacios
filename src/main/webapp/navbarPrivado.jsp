<%@ page import="java.util.*, com.reservas.Notificacion" %>
<%
    // ? Usar la variable implícita session
    if (session == null || session.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // ? Recuperar el nombre del usuario
    String usuarioNombre = (String) session.getAttribute("usuarioNombre");

    // ? Recuperar notificaciones (enviadas por el servlet)
    List<Notificacion> notificaciones = 
        (List<Notificacion>) request.getAttribute("notificaciones");
%>

<!-- ? Navbar Privada -->
<nav class="navbar navbar-expand-lg" style="background-color: #343a40;">
    <a class="navbar-brand text-white font-weight-bold" href="#">ReservaEspacios</a>

    <button class="navbar-toggler" type="button" data-toggle="collapse" 
            data-target="#navbarNav" aria-controls="navbarNav" 
            aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ml-auto">

            <li class="nav-item">
                <a class="nav-link text-white" href="MisReservasServlet">Mis Reservas</a>
            </li>

            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle text-white" href="#" id="navbarDropdown" role="button" data-toggle="dropdown">
                    ? Notificaciones 
                    <% if (notificaciones != null && !notificaciones.isEmpty()) { %>
                        <span class="badge badge-danger"><%= notificaciones.size() %></span>
                    <% } %>
                </a>
                <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdown" style="min-width: 300px; max-height: 400px; overflow-y: auto;">
                    <%
                        if (notificaciones != null && !notificaciones.isEmpty()) {
                            for (Notificacion n : notificaciones) {
                    %>
                                <a class="dropdown-item" href="#">
                                    <strong><%= n.getEstado() %></strong> - <%= n.getMensaje() %><br>
                                    <small class="text-muted"><%= n.getFecha() %></small>
                                </a>
                                <div class="dropdown-divider"></div>
                    <%
                            }
                        } else {
                    %>
                            <span class="dropdown-item text-muted">No tienes notificaciones</span>
                    <%
                        }
                    %>
                </div>
            </li>

            <li class="nav-item">
                <a class="nav-link text-white" href="perfilUsuario.jsp">
                    ? <%= usuarioNombre != null ? usuarioNombre : "Invitado" %>
                </a>
            </li>

            <li class="nav-item">
                <a class="btn btn-danger btn-sm ml-2" href="LogoutServlet">Cerrar Sesión</a>
            </li>
        </ul>
    </div>
</nav>
