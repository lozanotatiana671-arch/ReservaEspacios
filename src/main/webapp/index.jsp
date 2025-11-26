<%@page import="com.reservas.Testimonio"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, com.reservas.RecursoDAO, com.reservas.Recurso, com.reservas.BannerDAO, com.reservas.Banner, com.reservas.ReservaDAO, com.reservas.TestimonioDAO" %>

<%
    // ✅ Traer recursos
    List<Recurso> recursos = new ArrayList<>();
    try {
        recursos = RecursoDAO.listar();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // ✅ Traer banners activos
    List<Banner> banners = new ArrayList<>();
    try {
        BannerDAO bdao = new BannerDAO();
        for (Banner b : bdao.listar()) {
            if (b.isActivo()) banners.add(b);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }


    // ✅ Traer testimonios aprobados
    List<Testimonio> testimonios = new ArrayList<>();
    try { testimonios = new TestimonioDAO().listarAprobados(); } catch (Exception e) { e.printStackTrace(); }

    // ✅ Validar sesión de usuario
    HttpSession sesion = request.getSession(false);
    boolean usuarioLogueado = (sesion != null && sesion.getAttribute("usuarioId") != null);
    

    // ✅ Traer fechas con reservas (para el calendario)
    Set<String> fechasOcupadas = new HashSet<>();
    try {
        fechasOcupadas = RecursoDAO.obtenerFechasConReservas();
    } catch (Exception e) {
        e.printStackTrace();
    }
    
%>





<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reserva de Espacios</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
     <link rel="stylesheet" href="<%= request.getContextPath() %>/css/calendario.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilos.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/slider.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilotarjetas.css"> <!-- 🔹 Archivo externo -->
</head>

<body>

<!-- 🔹 Navbar -->
<%
    if (usuarioLogueado) {
%>
    <%@ include file="navbarPrivado.jsp" %>
<% } else { %>
    <%@ include file="navbarPublico.jsp" %>
<% } %>

<!-- 🔹 Slider dinámico -->
<div id="slider" class="carousel slide mt-3" data-ride="carousel" style="position: relative;">
    <div class="carousel-inner">
        <% if (!banners.isEmpty()) {
               int index = 0;
               for (Banner b : banners) { %>
                   <div class="carousel-item <%= (index == 0 ? "active" : "") %>">
                       <!-- 🔥 aquí el cambio: quitar "uploads/" -->
                       <img src="<%= b.getImagen() %>" class="d-block w-100" alt="<%= b.getTitulo() %>">
                       <div class="carousel-caption d-none d-md-block">
                           <h5><%= b.getTitulo() %></h5>
                       </div>
                   </div>
        <%         index++;
               }
           } else { %>
               <div class="carousel-item active">
                   <img src="img/slide1.jpg" class="d-block w-100" alt="Por defecto">
               </div>
        <% } %>
    </div>

    <!-- 🔹 Controles -->
    <a class="carousel-control-prev" href="#slider" role="button" data-slide="prev">
        <span class="carousel-control-prev-icon"></span>
    </a>
    <a class="carousel-control-next" href="#slider" role="button" data-slide="next">
        <span class="carousel-control-next-icon"></span>
    </a>
</div>


    <!-- 🔹 FORMULARIO SUPERPUESTO -->
    <div class="form-overlay">
        <form action="index.jsp" method="get" class="row justify-content-center align-items-center">
            <div class="col-lg-3 col-md-6 col-12 mb-2 text-center">
                <label>Fecha Entrada</label>
                <input type="date" name="fecha" class="form-control text-center" required>
            </div>
            <div class="col-lg-2 col-md-6 col-12 mb-2 text-center">
                <label>Hora de ingreso</label>
                <input type="time" name="horaInicio" class="form-control text-center" required>
            </div>
            <div class="col-lg-2 col-md-6 col-12 mb-2 text-center">
                <label>Hora de salida</label>
                <input type="time" name="horaFin" class="form-control text-center" required>
            </div>
            <div class="col-lg-3 col-md-6 col-12 mb-2 text-center">
                <label>Verificar disponibilidad</label>
                <button type="submit" class="btn btn-disponible rounded-pill px-4">
                    Ver disponibilidad
                </button>
            </div>
        </form>
    </div>
</div>

<br><br><br><br><br><br><br><br>

<section class="Espacios_calendario">
<%
    // ✅ Lógica de control
    String fecha = request.getParameter("fecha");
    String horaInicio = request.getParameter("horaInicio");
    String horaFin = request.getParameter("horaFin");

    boolean mostrarDisponibilidad = false;
    boolean verificar = (fecha != null && horaInicio != null && horaFin != null);

    if (verificar) {
        com.reservas.RecursoDAO rdaoDisp = new com.reservas.RecursoDAO();
        java.util.List<com.reservas.Recurso> recursosDisp = rdaoDisp.listar();
        for (com.reservas.Recurso r : recursosDisp) {
            if (r.isDisponible()) {
                mostrarDisponibilidad = true;
                break;
            }
        }
    }
%>

<% if (verificar) { %>
    <% if (mostrarDisponibilidad) { %>

   <!-- 🔹 Sección de Disponibilidad Mensual -->

<%
    // 🔹 Aquí NO declaramos nuevamente la variable — solo la reutilizamos
    fechasOcupadas.clear();  // ← esta línea reemplaza la declaración duplicada

    com.reservas.ReservaDAO reservaDAO_cal = new com.reservas.ReservaDAO();
    java.util.List<com.reservas.Reserva> reservasCal = reservaDAO_cal.listar();

    for (com.reservas.Reserva res : reservasCal) {
        String estado = res.getEstado();
        if (estado == null) continue;

        fechasOcupadas.add(res.getFecha());
    }
%>

<div class="container disponibilidad-container mt-5" id="disponibilidad">
  <div class="row">
    <!-- 🗓️ Calendario -->
 <!-- 🗓️ Calendario de disponibilidad -->
<!-- 🗓️ Calendario de disponibilidad -->
<div class="col-lg-6 col-md-12 mb-4">
  <div class="calendar-container shadow p-3 rounded">
    <div class="calendar-header d-flex justify-content-between align-items-center mb-3">
      <button id="prevMonth" class="btn btn-sm btn-outline-light">&#8592;</button>
      <h4 id="calendarTitle" class="mb-0" style="color:#FBE122;">📅 Disponibilidad</h4>
      <button id="nextMonth" class="btn btn-sm btn-outline-light">&#8594;</button>
    </div>
    <div id="calendar" class="calendar-grid"></div>
    <div class="mt-3 text-center legend">
      <span class="badge badge-available"></span> <small>Día disponible</small>
      &nbsp;&nbsp;
      <span class="badge badge-unavailable"></span> <small>No disponible</small>
    </div>
  </div>
</div>

<!-- 🧩 Script de calendario -->
<script>
document.addEventListener("DOMContentLoaded", function() {
  const calendar = document.getElementById("calendar");
  const title = document.getElementById("calendarTitle");
  let today = new Date();
  let currentMonth = today.getMonth();
  let currentYear = today.getFullYear();

  // 🔹 Fechas ocupadas enviadas desde JSP
  const fechasOcupadas = [
    <% for (String f : fechasOcupadas) { %>
      "<%= f %>",
    <% } %>
  ].map(f => f.trim());

  console.log("📅 Fechas ocupadas recibidas:", fechasOcupadas);

  // 🔹 Formato manual garantizado "YYYY-MM-DD" (sin UTC ni desfase)
  function formatFechaLocal(year, month, day) {
    const mm = String(month + 1).padStart(2, "0");
    const dd = String(day).padStart(2, "0");
    return `${year}-${mm}-${dd}`;
  }

  function generarCalendario(mes, año) {
    calendar.innerHTML = "";

    const firstDay = new Date(año, mes, 1).getDay();
    const daysInMonth = new Date(año, mes + 1, 0).getDate();

    const weekDays = ["L", "M", "M", "J", "V", "S", "D"];
    weekDays.forEach(d => {
      const header = document.createElement("div");
      header.classList.add("calendar-header-cell");
      header.textContent = d;
      calendar.appendChild(header);
    });

    // 🔹 Ajuste: lunes como primer día
    let startDay = firstDay === 0 ? 6 : firstDay - 1;
    for (let i = 0; i < startDay; i++) {
      const empty = document.createElement("div");
      empty.classList.add("calendar-empty");
      calendar.appendChild(empty);
    }

    // 🔹 Crear los días del mes
    for (let day = 1; day <= daysInMonth; day++) {
      const fecha = formatFechaLocal(año, mes, day);
      const cell = document.createElement("div");
      cell.classList.add("calendar-cell");
      cell.textContent = day;

      // 🔍 Depuración en consola
      console.log("Comparando:", fecha, "¿Ocupada?", fechasOcupadas.includes(fecha));

      if (fechasOcupadas.includes(fecha)) {
        cell.classList.add("unavailable-day");
        cell.title = "Reservas activas este día";
      } else {
        cell.classList.add("available-day");
        cell.title = "Día disponible";
      }

      cell.addEventListener("mouseover", () => cell.classList.add("hover"));
      cell.addEventListener("mouseout", () => cell.classList.remove("hover"));
      calendar.appendChild(cell);
    }

    const monthName = new Intl.DateTimeFormat('es-ES', { month: 'long' }).format(new Date(año, mes));
    title.textContent = monthName.charAt(0).toUpperCase() + monthName.slice(1) + " " + año;
  }

  document.getElementById("prevMonth").addEventListener("click", () => {
    currentMonth--;
    if (currentMonth < 0) {
      currentMonth = 11;
      currentYear--;
    }
    generarCalendario(currentMonth, currentYear);
  });

  document.getElementById("nextMonth").addEventListener("click", () => {
    currentMonth++;
    if (currentMonth > 11) {
      currentMonth = 0;
      currentYear++;
    }
    generarCalendario(currentMonth, currentYear);
  });

  generarCalendario(currentMonth, currentYear);
});
</script>







    <!-- 🏢 Carrusel de espacios disponibles -->
    <div class="col-lg-6 col-md-12">
      <div id="carruselEspacios" class="carousel slide" data-ride="carousel">
        <div class="carousel-inner">
          <%
              com.reservas.RecursoDAO recursoDAO = new com.reservas.RecursoDAO();
              java.util.List<com.reservas.Recurso> recursosCarrusel = recursoDAO.listar();
              int i = 0;
              for (com.reservas.Recurso r : recursosCarrusel) {
                  if (r.isDisponible()) {
          %>

          <!-- 🔹 Tarjeta dinámica con datos reales -->
          <div class="carousel-item <%= (i == 0 ? "active" : "") %>">
            <div class="space-card mx-auto" style="max-width: 380px;">
              <div class="space-img-container position-relative">
                 <img src="<%= (r.getImagen()!=null&&!r.getImagen().isEmpty())?
                request.getContextPath()+"/"+r.getImagen():request.getContextPath()+"/img/default-space.jpg" %>"
               alt="Imagen de <%= r.getNombre() %>" class="space-img">
          <div class="availability-badge <%= r.isDisponible()?"available":"unavailable" %>">
            <%= r.isDisponible() ? "Disponible" : ("EN_MANTENIMIENTO".equalsIgnoreCase(r.getEstado()) ? "En Mantenimiento" : "No Disponible") %>

          </div>
                <div class="location-badge">
                  📍 <%= r.getUbicacion()!=null?r.getUbicacion():"Ubicación no registrada" %>
                </div>
              </div>

              <div class="space-content text-center p-3">
                <h3 class="space-title"><%= r.getNombre() %></h3>
                <p class="space-description">
                  <%= r.getDescripcion()!=null&&!r.getDescripcion().isEmpty()?
                      r.getDescripcion():"Sin descripción disponible" %>
                </p>

                <div class="space-info d-flex justify-content-around mb-2">
                  <div class="info-box">
                    <span class="info-icon">👥</span>
                    <p><%= r.getCapacidad() %> personas</p>
                  </div>
                  <div class="info-box">
                    <span class="info-icon">💰</span>
                    <p>$<%= String.format("%,.2f", r.getTarifa()) %> COP</p>
                  </div>
                </div>

                <div class="space-rating">
                  <%
                    double promedio = r.getPromedioValoracion();
                    int totalResenas = r.getTotalResenas();
                    if (promedio > 0) {
                        int estrellas = (int)Math.round(promedio);
                  %>
                    <span class="stars"><% for(int j=1;j<=estrellas;j++){out.print("⭐");} %></span>
                    <span class="rating-value"><%= String.format("%.1f",promedio) %> (<%= totalResenas %> reseñas)</span>
                  <% } else { %>
                    <span class="rating-value text-muted">Sin calificaciones aún</span>
                  <% } %>
                </div>

                <a 
                  href="<%= r.isDisponible() ? "detalleEspacio.jsp?recursoId=" + r.getId() : "#" %>" 
                  class="reserve-btn <%= r.isDisponible() ? "" : "disabled" %>" 
                  <%= r.isDisponible() ? "" : "onclick='return false;' style=\"pointer-events:none; opacity:0.6; cursor:not-allowed;\"" %>>
                  <%= r.isDisponible() ? "📅 Reservar Ahora" : "🚫 No Disponible" %>
                </a>
              </div>
            </div>
          </div>

          <%
                  i++;
              }
          }
          %>
        </div>

        <!-- Controles del carrusel -->
        <a class="carousel-control-prev" href="#carruselEspacios" role="button" data-slide="prev">
          <span class="carousel-control-prev-icon"></span>
        </a>
        <a class="carousel-control-next" href="#carruselEspacios" role="button" data-slide="next">
          <span class="carousel-control-next-icon"></span>
        </a>
      </div>
    </div>
  </div>
</div>


    <% } else { %>
        <div class="alert alert-warning text-center mt-5" role="alert">
            🚫 No hay ningún espacio disponible para la fecha seleccionada.
        </div>
    <% } %>
<% } %>
</section>

<!-- 🔹 Sección de descripción de espacios -->
<section class="espacios-section text-center">
    <div class="container">
        <h2 class="titulo-espacios">
            <span class="titulo-normal">NUESTROS</span>
            <span class="titulo-resaltado">ESPACIOS</span>
        </h2>
        <h4 class="subtitulo-espacios">PRÉSTAMO PARA LOGROS Y TRAZOS</h4>
        <p class="descripcion-espacios">
            Abrimos las puertas para que tus proyectos, sueños y actividades cobren vida en un entorno diseñado para inspirar, conectar y crecer. 
            Nuestros espacios son más que lugares físicos: son escenarios donde el conocimiento, la creatividad y la comunidad se encuentran para dar forma a nuevas oportunidades. 
            Creemos que al brindar un espacio, se siembran posibilidades, porque en cada encuentro las ideas se transforman en experiencias, 
            los proyectos en realidades y las personas en verdaderos agentes de cambio.
        </p>
    </div>
</section>

<!-- 🔹 Sección de espacios -->
<div class="container mt-5">
  <div class="row">
  <% if (recursos != null && !recursos.isEmpty()) {
       for (Recurso r : recursos) { %>
    <div class="col-md-4 mb-4">
      <div class="space-card shadow">
        <div class="space-img-container position-relative">
          <img src="<%= (r.getImagen()!=null&&!r.getImagen().isEmpty())?
                request.getContextPath()+"/"+r.getImagen():request.getContextPath()+"/img/default-space.jpg" %>"
               alt="Imagen de <%= r.getNombre() %>" class="space-img">
          <div class="availability-badge <%= r.isDisponible()?"available":"unavailable" %>">
            <%= r.isDisponible() ? "Disponible" : ("EN_MANTENIMIENTO".equalsIgnoreCase(r.getEstado()) ? "En Mantenimiento" : "No Disponible") %>

          </div>
          <div class="location-badge">📍 <%= r.getUbicacion()!=null?r.getUbicacion():"Ubicación no registrada" %></div>
        </div>

        <div class="space-content p-3">
          <h3 class="space-title"><%= r.getNombre() %></h3>
          <p class="space-description"><%= r.getDescripcion()!=null&&!r.getDescripcion().isEmpty()?r.getDescripcion():"Sin descripción disponible" %></p>

          <div class="space-info d-flex justify-content-around mb-2">
            <div class="info-box"><span class="info-icon">👥</span><p><%= r.getCapacidad() %> personas</p></div>
            <div class="info-box"><span class="info-icon">💰</span><p>$<%= String.format("%,.2f", r.getTarifa()) %> COP</p></div>
          </div>

          <div class="space-rating">
            <%
              double promedio = r.getPromedioValoracion();
              int totalResenas = r.getTotalResenas();
              if (promedio > 0) {
                  int estrellas = (int)Math.round(promedio);
            %>
              <span class="stars"><% for(int j=1;j<=estrellas;j++){out.print("⭐");} %></span>
              <span class="rating-value"><%= String.format("%.1f",promedio) %> (<%= totalResenas %> reseñas)</span>
            <% } else { %>
              <span class="rating-value text-muted">Sin calificaciones aún</span>
            <% } %>
          </div>

          <%
    // 🟢 Leer el estado del recurso
    String estado = r.getEstado() != null ? r.getEstado().toUpperCase() : "NO_DISPONIBLE";

    // Variables para personalizar el botón
    String textoBoton = "";
    String claseBoton = "";
    String hrefBoton = "#";
    String estiloExtra = "";

    // Cambiar según el estado
    switch (estado) {
        case "DISPONIBLE":
            textoBoton = "📅 Reservar Ahora";
            claseBoton = "reserve-btn btn-success";
            hrefBoton = "detalleEspacio.jsp?recursoId=" + r.getId();
            break;
        case "EN_MANTENIMIENTO":
            textoBoton = "🔧 En Mantenimiento";
            claseBoton = "reserve-btn";
            estiloExtra = "background-color:#FBE122; color:#FFFFFF; border:none; pointer-events:none; opacity:0.5; cursor:not-allowed;";
            break;

        case "NO_DISPONIBLE":
        default:
            textoBoton = "🚫 No Disponible";
            claseBoton = "reserve-btn btn-secondary disabled";
            estiloExtra = "pointer-events:none; opacity:0.6; cursor:not-allowed;";
            break;
    }
%>

<!-- 🔹 Botón dinámico según estado -->
<a href="<%= hrefBoton %>" class="<%= claseBoton %>" style="<%= estiloExtra %>">
  <%= textoBoton %>
</a>


        </div>
      </div>
    </div>
  <% } } else { %>
    <div class="col-12 text-center"><p>No hay recursos disponibles por el momento.</p></div>
  <% } %>
  </div>
</div>

<!-- 🔹 Sección testimonios -->
<section class="testimonios-section">
  <div class="container text-center">
    <h2 class="titulo-testimonios">TESTIMONIOS DE NUESTROS CLIENTES</h2>
    <p class="descripcion-testimonios">
      Conoce las experiencias de quienes ya hicieron parte de esta comunidad.
      Sus palabras reflejan la satisfacción, la confianza y el impacto positivo
      de vivir momentos únicos en nuestros espacios diseñados para inspirar, conectar y crear.
    </p>
  </div>
</section>

<!-- 🔹 Carrusel de testimonios -->
<div class="testimonios-slider-wrapper">
  <div class="testimonios-container">
    <div class="testimonios-track">
      <% if (testimonios != null && !testimonios.isEmpty()) {
           for (Testimonio t : testimonios) { %>
        <div class="testimonio-card">
          <div class="testimonio-body">
            <p class="testimonio-text">"<%= t.getMensaje() %>"</p>
          </div>
          <div class="testimonio-footer text-right">
            <small>- <%= t.getUsuarioNombre() %></small>
          </div>
        </div>
      <% } } else { %>
        <p class="text-center">No hay testimonios aprobados todavía.</p>
      <% } %>
    </div>

    <!-- 🔹 Indicadores -->
    <div class="slider-indicators">
      <span class="dot active"></span>
      <span class="dot"></span>
      <span class="dot"></span>
    </div>
  </div>
</div>

<!-- 🔹 Footer -->
<footer class="text-white text-center p-3 mt-5 bg-dark">
  <p>&copy; 2025 Sistema de Reservas - Todos los derechos reservados</p>
</footer>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
