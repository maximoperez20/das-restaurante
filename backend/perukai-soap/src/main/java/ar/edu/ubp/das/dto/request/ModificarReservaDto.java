package ar.edu.ubp.das.dto.request;

public class ModificarReservaDto {
  private String codReserva;
  private String codZona;
  private String fechaReserva;
  private String horaDesde;
  private Integer cantAdultos;
  private Integer cantMenores;

  public ModificarReservaDto() {
  }

  public ModificarReservaDto(String codReserva, String codZona, String fechaReserva, String horaDesde, Integer cantAdultos, Integer cantMenores) {
    this.codReserva = codReserva;
    this.codZona = codZona;
    this.fechaReserva = fechaReserva;
    this.horaDesde = horaDesde;
    this.cantAdultos = cantAdultos;
    this.cantMenores = cantMenores;
  }

  public String getCodReserva() {
    return codReserva;
  }

  public void setCodReserva(String codReserva) {
    this.codReserva = codReserva;
  }
  
  public String getCodZona() {
    return codZona;
  }

  public void setCodZona(String codZona) {
    this.codZona = codZona;
  }
  
  public String getFechaReserva() {
    return fechaReserva;
  }

  public void setFechaReserva(String fechaReserva) {
    this.fechaReserva = fechaReserva;
  }
  
  public String getHoraDesde() {
    return horaDesde;
  }

  public void setHoraDesde(String horaDesde) {
    this.horaDesde = horaDesde;
  }
  
  public Integer getCantAdultos() {
    return cantAdultos;
  }

  public void setCantAdultos(Integer cantAdultos) {
    this.cantAdultos = cantAdultos;
  }

  public Integer getCantMenores() {
    return cantMenores;
  }

  public void setCantMenores(Integer cantMenores) {
    this.cantMenores = cantMenores;
  }
}
