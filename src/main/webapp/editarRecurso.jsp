<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="com.reservas.Recurso, com.reservas.RecursoDAO" %>

<%
    // Sesión del administrador
    HttpSession sesion = request.getSession(false);
    String adminNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : "Admin";
%>


<%
    int id = Integer.parseInt(request.getParameter("id"));
    Recurso r = null;
    try {
        for (Recurso rec : RecursoDAO.listar()) {
            if (rec.getId() == id) {
                r = rec;
                break;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Administrador</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>

<body>
  <!-- 🔹 Navbar para administrador -->
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
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet?action=listar">⚙️ Recursos</a></li>
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

      <!-- Menú lateral -->
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

      <!-- Contenido principal -->
      <main class="col-md-10 content-area">
        <h2><i class="bi bi-building"></i> Editar Recurso</h2>

        <div class="form-card">
          <!-- 🔹 Backend integrado -->
          <form action="ActualizarRecursoServlet" method="post" enctype="multipart/form-data">
            <input type="hidden" name="id" value="<%= r.getId() %>">
            <input type="hidden" name="imagenActual" value="<%= r.getImagen() %>">

            <!-- Nombre -->
            <div class="form-group">
              <label for="nombre">Nombre</label>
              <input id="nombre" type="text" name="nombre" class="form-control" value="<%= r.getNombre() %>" required>
            </div>

            <!-- Fila 1: Tipo + Capacidad + Estado -->
            <div class="row">
              <div class="col-md-4">
                <div class="form-group">
                  <label for="tipo">Tipo</label>
                  <select id="tipo" name="tipo" class="form-control" required>
                    <option value="SALON" <%= "SALON".equalsIgnoreCase(r.getTipo()) ? "selected" : "" %>>Salón</option>
                    <option value="LABORATORIO" <%= "LABORATORIO".equalsIgnoreCase(r.getTipo()) ? "selected" : "" %>>Laboratorio</option>
                    <option value="EQUIPO" <%= "EQUIPO".equalsIgnoreCase(r.getTipo()) ? "selected" : "" %>>Equipo</option>
                  </select>
                </div>
              </div>

              <div class="col-md-4">
                <div class="form-group">
                  <label for="capacidad">Capacidad</label>
                  <input id="capacidad" type="number" name="capacidad" class="form-control" value="<%= r.getCapacidad() %>" min="1">
                </div>
              </div>

              <div class="col-md-4">
                  <div class="form-group">
                      <label for="estado">Estado</label>
                      <select id="estado" name="estado" class="form-control">
                          <option value="DISPONIBLE" <%= "DISPONIBLE".equalsIgnoreCase(r.getEstado()) ? "selected" : "" %>>Disponible</option>
                          <option value="EN_MANTENIMIENTO" <%= "EN_MANTENIMIENTO".equalsIgnoreCase(r.getEstado()) ? "selected" : "" %>>En mantenimiento</option>
                          <option value="NO_DISPONIBLE" <%= "NO_DISPONIBLE".equalsIgnoreCase(r.getEstado()) ? "selected" : "" %>>No disponible</option>
                      </select>
                  </div>
              </div>
            </div>

            <!-- Fila 2: Ubicación + Tarifa -->
            <div class="row">
              <div class="col-md-6">
                <div class="form-group">
                  <label for="ubicacion">Ubicación</label>
                  <input id="ubicacion" type="text" name="ubicacion" class="form-control"
                         value="<%= r.getUbicacion() != null ? r.getUbicacion() : "" %>" placeholder="Ej: Edif. B, Piso 1">
                </div>
              </div>

              <div class="col-md-6">
                <div class="form-group">
                  <label for="tarifa">Tarifa (COP)</label>
                  <input id="tarifa" type="number" step="0.01" name="tarifa" class="form-control" value="<%= r.getTarifa() %>" required>
                </div>
              </div>
            </div>

            <!-- Descripción e Imagen -->
            <div class="row">
              <div class="col-md-8">
                <div class="form-group">
                  <label for="descripcion">Descripción</label>
                  <textarea id="descripcion" name="descripcion" class="form-control"><%= r.getDescripcion() %></textarea>
                </div>
              </div>

              <div class="col-md-4">
                <div class="form-group">
                  <label>Imagen actual</label><br>
                 <% 
    String imagen = r.getImagen();
    boolean esURL = (imagen != null && (imagen.startsWith("http://") || imagen.startsWith("https://")));
%>

<% if (imagen != null && !imagen.isEmpty()) { %>

    <% if (esURL) { %>
        <!-- Imagen guardada en GitHub (URL absoluta) -->
        <img src="<%= imagen %>" 
             alt="Imagen recurso" style="max-width:150px; border-radius:8px;">
    <% } else { %>
        <!-- Imagen guardada local en uploads/ -->
        <img src="<%= request.getContextPath() + "/" + imagen %>"
             alt="Imagen recurso" style="max-width:150px; border-radius:8px;">
    <% } %>

<% } else { %>
    <p class="text-muted">No hay imagen cargada</p>
<% } %>


                  <div class="mt-2">
                    <label for="imagen">Cambiar imagen (opcional)</label>
                    <input id="imagen" type="file" name="imagen" class="form-control-file" accept="image/*">
                  </div>
                </div>
              </div>
            </div>

            <!-- Checkbox -->
            <div class="form-check">
              <input id="disponible" type="checkbox" name="disponible" class="form-check-input" <%= r.isDisponible() ? "checked" : "" %>>
              <label class="form-check-label" for="disponible">Disponible para reservas</label>
            </div>

            <!-- Botones -->
            <div class="form-actions">
              <button type="submit" class="btn-guardar">
                <i class="bi bi-save"></i> Actualizar
              </button>
              <a href="ListaRecursosServlet?action=listar" class="btn-cancelar">
                <i class="bi bi-x-circle"></i> Cancelar
              </a>
            </div>
          </form>
        </div>
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
</body>
</html>
