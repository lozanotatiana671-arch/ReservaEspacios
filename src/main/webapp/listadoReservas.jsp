<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.reservas.Reserva" %>
<%
    // 🔹 Sesión del administrador
    HttpSession sesion = request.getSession(false);
    String adminNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : "Admin";

 %> 

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Administrador</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
</head>
<body>

  <!-- 🔹 Navbar superior -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="ListaReservasServlet">SistemaReserva</a>

    <button class="navbar-toggler" type="button" data-toggle="collapse"
            data-target="#navbarNav" aria-controls="navbarNav"
            aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item"><a class="nav-link" href="ListaReservasServlet">📋 Reservas</a></li>
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet">⚙️ Recursos</a></li>
            <li class="nav-item"><a class="nav-link" href="UsuarioServlet?action=listar">👤 Usuarios</a></li>
            <li class="nav-item"><a class="nav-link" href="ReporteServlet">📊 Reportes</a></li>
        </ul>


        <span class="navbar-text text-white mr-3">
            👤 <%= adminNombre %>
        </span>
        <a href="LogoutServlet" class="btn btn-logout btn-sm btn-outline-light">Cerrar Sesión</a>
    </div>
  </nav>

  <!-- Botón menú móvil -->
  <button class="menu-toggle" id="menuToggle">
    <i class="fas fa-bars"></i>
  </button>

  <div class="container-fluid">
    <div class="row" style="margin-right: -20px;">

      <!-- 🔹 Menú lateral -->
      <nav class="col-md-2 side-menu" style="margin-right: -20px;" id="sideMenu">
        <h4><i class="fas fa-cogs"></i> Administración</h4>
        <a href="UsuarioServlet?action=listar"><i class="fas fa-users"></i> Usuarios</a>
        <a href="configuracion.jsp"><i class="fas fa-cog"></i> Configuración</a>
        <a href="BannerServlet"><i class="fas fa-image"></i> Banner</a>
        <hr>
        <a href="ListaReservasServlet"><i class="fas fa-calendar-check"></i> Gestionar Reservas</a>
        <a href="TestimonioServlet?action=listar"><i class="fas fa-comment-alt"></i> Gestionar Testimonios</a>
        <a href="ListaConsultasServlet?action=listar"><i class="fas fa-envelope"></i> Gestionar Consultas</a>
        <hr>
        <a href="nuevoRecurso.jsp"><i class="fas fa-plus-circle"></i> Nuevo Espacio</a>
        <a href="ListaRecursosServlet?action=listar"><i class="fas fa-building"></i> Gestionar Espacios</a>
        <a href="ReporteServlet"><i class="fas fa-chart-bar"></i> Reportes</a>
      </nav>

      <!-- 🔹 Contenido principal -->
      <main class="col-md-10 content-area">
        <h2 class="main-header">Panel de Administrador</h2>

        <!-- 🔸 Tarjetas resumen -->
        <div class="row">
          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card-dashboard">
              <div class="card-dashboard-content">
                <h5><i class="fas fa-calendar-alt"></i> Total Reservas</h5>
                <h2><%= request.getAttribute("totalReservas") != null ? request.getAttribute("totalReservas") : 0 %></h2>
                <a href="ListaReservasServlet" class="btn btn-outline-primary btn-sm">VER DETALLE</a>
              </div>
            </div>
          </div>

          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card-dashboard">
              <div class="card-dashboard-content">
                <h5><i class="fas fa-building"></i> Espacios</h5>
                <h2><%= request.getAttribute("totalEspacios") != null ? request.getAttribute("totalEspacios") : 0 %></h2>
                <a href="ListaRecursosServlet?action=listar" class="btn btn-outline-primary btn-sm">VER DETALLE</a>
              </div>
            </div>
          </div>

          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card-dashboard">
              <div class="card-dashboard-content">
                <h5><i class="fas fa-comments"></i> Testimonios</h5>
                <h2><%= request.getAttribute("totalTestimonios") != null ? request.getAttribute("totalTestimonios") : 0 %></h2>
                <a href="TestimonioServlet?action=listar" class="btn btn-outline-primary btn-sm">VER DETALLE</a>
              </div>
            </div>
          </div>

          <div class="col-lg-3 col-md-6 col-sm-6">
            <div class="card-dashboard">
              <div class="card-dashboard-content">
                <h5><i class="fas fa-users"></i> Clientes</h5>
                <h2><%= request.getAttribute("totalClientes") != null ? request.getAttribute("totalClientes") : 0 %></h2>
                <a href="UsuarioServlet?action=listar" class="btn btn-outline-primary btn-sm">VER DETALLE</a>
              </div>
            </div>
          </div>
        </div>

        <!-- 🔸 Filtro de reservas -->
        <div class="table-container">
          <div class="filtro-reservas mt-4 mb-4 p-3 border rounded bg-light shadow-sm">
            <form method="post" action="ListaReservasServlet" class="form-inline justify-content-between align-items-center">
              <div class="form-group mb-2">
                <label for="estado" class="mr-2 font-weight-bold text-dark">
                  <i class="fas fa-filter"></i> Filtrar por estado:
                </label>
                <select id="estado" name="estado" class="form-control">
                  <option value="">-- Todos --</option>
                  <option value="Pendiente" <%= "Pendiente".equals(request.getParameter("estado")) ? "selected" : "" %>>Pendiente</option>
                  <option value="Aprobada" <%= "Aprobada".equals(request.getParameter("estado")) ? "selected" : "" %>>Aprobada</option>
                  <option value="Prestado" <%= "Prestado".equals(request.getParameter("estado")) ? "selected" : "" %>>Prestado</option>
                  <option value="Finalizado" <%= "Finalizado".equals(request.getParameter("estado")) ? "selected" : "" %>>Finalizado</option>
                  <option value="Rechazada" <%= "Rechazada".equals(request.getParameter("estado")) ? "selected" : "" %>>Rechazada</option>
                </select>
              </div>

              <div class="form-group mb-2">
                <button type="submit" class="btn btn-success">
                  <i class="fas fa-search"></i> Aplicar filtro
                </button>
                <a href="ListaReservasServlet" class="btn btn-secondary ml-2">
                  <i class="fas fa-sync-alt"></i> Limpiar
                </a>
              </div>
            </form>
          </div>
        </div><br>

        <!-- 🔸 Tabla de reservas -->
        <h4><i class="fas fa-list"></i> Listado de Reservas</h4>
        <div class="table-responsive">
          <table class="table table-bordered table-striped">
            <thead class="thead-dark">
              <tr>
                <th>ID</th>
                <th>Usuario</th>
                <th>Recurso</th>
                <th>Fecha</th>
                <th>Hora</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <%
                List<Reserva> reservas = (List<Reserva>) request.getAttribute("reservas");
                if (reservas != null && !reservas.isEmpty()) {
                    for (Reserva r : reservas) {
              %>
                <tr>
                  <td><%= r.getId() %></td>
                  <td><%= r.getNombre() %></td>
                  <td><%= r.getRecursoNombre() != null ? r.getRecursoNombre() : "-" %></td>
                  <td><%= r.getFecha() %></td>
                  <td><%= r.getHoraInicio() %> - <%= r.getHoraFin() %></td>
                  <td><span class="badge badge-info"><%= r.getEstado() %></span></td>
                  <td>
                    <% String estadoReserva = r.getEstado(); %>

                    <!-- ✅ Botón Aprobar -->
                    <a href="CambiarEstadoServlet?id=<%= r.getId() %>&estado=Aprobada"
                       class="btn btn-success btn-sm <%= ("Aprobada".equalsIgnoreCase(estadoReserva) || 
                                                          "Prestado".equalsIgnoreCase(estadoReserva) || 
                                                          "Finalizado".equalsIgnoreCase(estadoReserva)) ? "disabled" : "" %>"
                       <%= ("Aprobada".equalsIgnoreCase(estadoReserva) || 
                            "Prestado".equalsIgnoreCase(estadoReserva) || 
                            "Finalizado".equalsIgnoreCase(estadoReserva)) 
                            ? "tabindex='-1' aria-disabled='true' style='pointer-events:none;opacity:0.6;'" : "" %>>
                       <i class="fas fa-check"></i> Aprobar
                    </a>

                    <!-- ✅ Botón Prestar -->
                    <a href="CambiarEstadoServlet?id=<%= r.getId() %>&estado=Prestado"
                       class="btn btn-warning btn-sm <%= ("Prestado".equalsIgnoreCase(estadoReserva) || 
                                                          "Finalizado".equalsIgnoreCase(estadoReserva) || 
                                                          "Rechazada".equalsIgnoreCase(estadoReserva)) ? "disabled" : "" %>"
                       <%= ("Prestado".equalsIgnoreCase(estadoReserva) || 
                            "Finalizado".equalsIgnoreCase(estadoReserva) || 
                            "Rechazada".equalsIgnoreCase(estadoReserva)) 
                            ? "tabindex='-1' aria-disabled='true' style='pointer-events:none;opacity:0.6;cursor:not-allowed;'" : "" %>>
                       <i class="fas fa-key"></i> Prestar
                    </a>

                    <!-- ✅ Botón Finalizar -->
                    <a href="CambiarEstadoServlet?id=<%= r.getId() %>&estado=Finalizado"
                       class="btn btn-secondary btn-sm <%= ("Finalizado".equalsIgnoreCase(estadoReserva) || 
                                                            "Rechazada".equalsIgnoreCase(estadoReserva)) ? "disabled" : "" %>"
                       <%= ("Finalizado".equalsIgnoreCase(estadoReserva) || 
                            "Rechazada".equalsIgnoreCase(estadoReserva)) 
                            ? "tabindex='-1' aria-disabled='true' style='pointer-events:none;opacity:0.6;cursor:not-allowed;'" : "" %>>
                       <i class="fas fa-flag"></i> Finalizar
                    </a>
                  </td>
                </tr>
              <%
                    }
                } else {
              %>
                <tr>
                  <td colspan="7" class="text-center">No hay reservas registradas</td>
                </tr>
              <%
                }
              %>
            </tbody>
          </table>
        </div>

        <!-- 🔸 Paginación -->
        <nav class="mt-3">
          <ul class="pagination justify-content-center">
            <%
              int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
              int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
            %>
            <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
              <a class="page-link" href="?page=<%= currentPage - 1 %>"><i class="fas fa-chevron-left"></i></a>
            </li>

            <%
              for (int i = 1; i <= totalPages; i++) {
            %>
              <li class="page-item <%= i == currentPage ? "active" : "" %>">
                <a class="page-link" href="?page=<%= i %>"><%= i %></a>
              </li>
            <%
              }
            %>

            <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
              <a class="page-link" href="?page=<%= currentPage + 1 %>"><i class="fas fa-chevron-right"></i></a>
            </li>
          </ul>
        </nav>
      </main>
    </div>
  </div>

  <!-- Script menú móvil -->
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const menuToggle = document.getElementById('menuToggle');
      const sideMenu = document.getElementById('sideMenu');
      
      if (menuToggle && sideMenu) {
        menuToggle.addEventListener('click', function() {
          sideMenu.classList.toggle('active');
        });
        
        document.addEventListener('click', function(event) {
          if (window.innerWidth <= 767) {
            const isClickInside = sideMenu.contains(event.target) || menuToggle.contains(event.target);
            if (!isClickInside && sideMenu.classList.contains('active')) {
              sideMenu.classList.remove('active');
            }
          }
        });
      }
    });
  </script>

  <!-- Bootstrap JS -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
