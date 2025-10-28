<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.reservas.Banner" %>

<%
    // 🔹 Sesión del administrador
    HttpSession sesion = request.getSession(false);
    String adminNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : "Admin";

    // 🔹 Mensaje recibido desde el servlet (opcional)
    String mensaje = (String) request.getAttribute("mensaje");

    // 🔹 Si se está editando un banner
    Banner bannerEdit = (Banner) request.getAttribute("banner");
    String idValue = bannerEdit != null ? String.valueOf(bannerEdit.getId()) : "";
    String tituloValue = bannerEdit != null ? bannerEdit.getTitulo() : "";
    String imagenAnterior = bannerEdit != null ? bannerEdit.getImagen() : "";
    boolean activoChecked = bannerEdit != null && bannerEdit.isActivo();
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
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet">⚙️ Recursos</a></li>
            <li class="nav-item"><a class="nav-link" href="UsuarioServlet?action=listar">👤 Usuarios</a></li>
            <li class="nav-item"><a class="nav-link" href="ReporteServlet">📊 Reportes</a></li>
        </ul>

        <span class="navbar-text text-white mr-3">👤 <%= adminNombre %></span>
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

      <h2><i class="bi bi-images"></i> Gestión de Banners</h2>

      <!-- Mostrar mensaje desde el servlet -->
      <% if (mensaje != null && !mensaje.isEmpty()) { %>
        <div class="alert alert-danger"><%= mensaje %></div>
      <% } %>

      <!-- Formulario -->
      <div class="form-card">
        <form action="BannerServlet" method="post" enctype="multipart/form-data">
          <input type="hidden" name="id" value="<%= idValue %>">
          <input type="hidden" name="imagenAnterior" value="<%= imagenAnterior %>">

          <div class="form-group">
           <label><i class="bi bi-type"></i> Título <span class="text-danger">*</span></label>
           <input type="text" name="titulo" id="titulo" class="form-control" 
            placeholder="Ej: Promoción Semestral" value="<%= tituloValue %>" required
            oninvalid="this.setCustomValidity('Por favor, ingrese un título para el banner')"
            oninput="this.setCustomValidity('')">
      </div>

      <div class="form-group">
      <label><i class="bi bi-file-image"></i> Imagen <span class="text-danger">*</span></label>
      <input type="file" name="imagen" id="imagen" class="form-control-file" 
         accept="image/png, image/jpeg" onchange="previewImage(this)">
      <small class="form-text text-muted">
      Formatos permitidos: JPG o PNG. Tamaño máximo: 10MB
      </small>
      <div class="preview-container mt-2">
      <% if (imagenAnterior != null && !imagenAnterior.isEmpty()) { %>
      <img id="imgPreview" src="<%= request.getContextPath() %>/image/<%= imagenAnterior %>" class="preview-img rounded shadow-sm">
      <% } else { %>
      <img id="imgPreview" class="preview-img" style="display:none;">
      <% } %>
    </div>
</div>

 
<div class="form-check mt-3" >
  <input 
    type="checkbox" 
    name="activo" 
    class="form-check-input" 
    id="activo"
    <%= (bannerEdit != null && bannerEdit.isActivo()) ? "checked" : "" %>
   sty>
  <label class="form-check-label" for="activo">
    <i class="bi bi-check-circle"></i> Activo
  </label>
</div>


<div class="form-actions">
  <!-- Botón principal -->
  <button type="submit" class="btn-guardar">
    <i class="bi bi-cloud-upload"></i> <%= bannerEdit != null ? "Actualizar Banner" : "Guardar Banner" %>
  </button>

  <!-- Botón secundario dinámico -->
  <%
    if (bannerEdit != null) {  // Si estás editando
  %>
      <a href="BannerServlet?accion=listar" class="btn btn-restablecer">
        <i class="bi bi-x-circle"></i> Cancelar
      </a>
  <%
    } else {  // Si estás creando
  %>
      <button type="reset" class="btn btn-restablecer">
        <i class="bi bi-arrow-repeat"></i> Restablecer
      </button>
  <%
    }
  %>
</div>

        </form>
      </div>

      <!-- Tabla -->
      <div class="table-section">
        <h3><i class="bi bi-list"></i> Banners registrados</h3>
        <table class="table table-custom mb-0">
          <thead>
            <tr>
              <th>ID</th>
              <th>Título</th>
              <th>Imagen</th>
              <th>Activo</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <%
              List<Banner> banners = (List<Banner>) request.getAttribute("banners");
              if (banners != null && !banners.isEmpty()) {
                for (Banner b : banners) {
            %>
              <tr>
                <td><%= b.getId() %></td>
                <td><%= b.getTitulo() %></td>
                <td>
                  <% if (b.getImagen() != null && !b.getImagen().isEmpty()) { %>
                   <img src="<%= request.getContextPath() %>/uploads/<%= b.getImagen() %>" width="120" alt="Banner">

                  <% } %>
                </td>
                <td><i class="bi <%= b.isActivo() ? "bi-check-circle text-success" : "bi-x-circle text-danger" %>"></i> <%= b.isActivo() ? "Sí" : "No" %></td>
                <td>
                  <a href="BannerServlet?accion=editar&id=<%= b.getId() %>" class="btn btn-warning btn-sm">
                    <i class="bi bi-pencil"></i> Editar
                  </a>
                  <a href="BannerServlet?accion=eliminar&id=<%= b.getId() %>" class="btn btn-danger btn-sm"
                     onclick="return confirm('¿Seguro que deseas eliminar este banner?')">
                    <i class="bi bi-trash"></i> Eliminar
                  </a>
                </td>
              </tr>
            <%
                }
              } else {
            %>
              <tr>
                <td colspan="5" class="text-center py-3 text-muted">
                  <i class="bi bi-inbox"></i> No hay banners registrados
                </td>
              </tr>
            <%
              }
            %>
          </tbody>
        </table>
      </div>
      
    </main>
  </div>
</div>

  <script>
    function previewImage(input) {
      const preview = document.getElementById('imgPreview');
      if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
          preview.src = e.target.result;
          preview.style.display = 'block';
        };
        reader.readAsDataURL(input.files[0]);
      }
    }
  </script>

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
