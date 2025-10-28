<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    // 🔹 Validar sesión del usuario
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int usuarioId = (int) sesion.getAttribute("usuarioId");
    String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");

    // 🔹 ID del recurso
    String idRecursoParam = request.getParameter("idRecurso");
    int idRecurso = (idRecursoParam != null && !idRecursoParam.isEmpty())
                    ? Integer.parseInt(idRecursoParam) : 0;

    String mensajeSistema = (String) request.getAttribute("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Testimonio - ReservaEspacios</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- CSS externo -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfilUsuario.css">

  <style>
.rating-container {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  font-size: 2rem;
  cursor: pointer;
  margin-top: 10px;
}

.rating-star {
  color: #ccc;
  transition: color 0.3s ease, transform 0.2s ease;
}

.rating-star:hover,
.rating-star:hover ~ .rating-star {
  color: #DAAA00;
  transform: scale(1.1);
}

.rating-star.selected {
  color: #007B3E;
}

.rating-label {
  font-weight: bold;
  color: #00482B;
  margin-right: 10px;
  text-align: center;
  display: block;
}
  </style>

</head>
<body>

  <!-- 🔹 Sidebar -->
  <div class="sidebar">
    <a class="navbar-brand" href="perfilUsuario.jsp">ReservaEspacios</a>
    <ul class="nav flex-column mt-4">
      <li class="nav-item">
        <a class="nav-link" href="perfilUsuario.jsp"><i class="fas fa-user"></i> Mi Perfil</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="MisReservasServlet"><i class="fas fa-calendar-check"></i> Mis Reservas</a>
      </li>
      <li class="nav-item">
        <a class="nav-link active" href="#"><i class="fas fa-comment-dots"></i> Mis Testimonios</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="NotificacionesServlet"><i class="fas fa-bell"></i> Notificaciones</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
      </li>
    </ul>
  </div>

  <!-- Contenido Principal -->
  <div class="content">
    <div class="header">
      <h2 class="mb-0">💬 Deja tu Testimonio</h2>
      <div class="user-info">
        <i class="fas fa-user"></i> <span>Hey, <%= usuarioNombre %></span>
      </div>
    </div>

    <div class="testimonio-section">
      <h2 class="text-center mb-4">💬 Cuéntanos tu experiencia</h2>

      <p class="intro-text">
        ✨ Tu opinión es muy importante para mejorar nuestros espacios ✨
      </p>

      <!-- ✅ Formulario -->
      <form action="TestimonioServlet" method="post" id="testimonioForm">
        <input type="hidden" name="idRecurso" value="<%= idRecurso %>">

        <!-- ✅ Calificación -->
        <div class="rating-container text-center mb-4">
          <label class="rating-label"><strong>Calificación:</strong></label><br>
          <span class="rating-star" data-value="1">★</span>
          <span class="rating-star" data-value="2">★</span>
          <span class="rating-star" data-value="3">★</span>
          <span class="rating-star" data-value="4">★</span>
          <span class="rating-star" data-value="5">★</span>
          <input type="hidden" id="calificacion" name="calificacion" value="0">
        </div>

        <div class="form-group">
          <label for="mensaje">Escribe tu experiencia</label>
          <textarea name="mensaje" id="mensaje" class="form-control" rows="3" required
            placeholder="Cuéntanos sobre tu experiencia con este espacio..."></textarea>
        </div>

        <button type="submit" class="btn btn-success btn-block">Enviar Testimonio</button>
      </form>

      <% if (mensajeSistema != null) { %>
        <p class="text-success text-center mt-3"><%= mensajeSistema %></p>
      <% } %>

    </div>
  </div>

  <!-- ✅ Scripts (al final para que funcionen las estrellas) -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    const stars = document.querySelectorAll('.rating-star');
    const input = document.getElementById('calificacion');

    stars.forEach((star, index) => {
      star.addEventListener('click', () => {
        stars.forEach(s => s.classList.remove('selected'));
        for (let i = 0; i <= index; i++) {
          stars[i].classList.add('selected');
        }
        input.value = star.dataset.value;
      });
    });
  </script>
</body>
</html>
