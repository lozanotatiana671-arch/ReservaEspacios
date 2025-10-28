package com.reservas;

public class Reserva {
    private int id;
    private String nombre;
    private String fecha;
    private String horaInicio;
    private String horaFin;
    private String estado;
    private int recursoId;
    private String recursoNombre;
    private int usuarioId;

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }

    public String getHoraInicio() { return horaInicio; }
    public void setHoraInicio(String horaInicio) { this.horaInicio = horaInicio; }

    public String getHoraFin() { return horaFin; }
    public void setHoraFin(String horaFin) { this.horaFin = horaFin; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public int getRecursoId() { return recursoId; }
    public void setRecursoId(int recursoId) { this.recursoId = recursoId; }

    public String getRecursoNombre() { return recursoNombre; }
    public void setRecursoNombre(String recursoNombre) { this.recursoNombre = recursoNombre; }

    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }
}
