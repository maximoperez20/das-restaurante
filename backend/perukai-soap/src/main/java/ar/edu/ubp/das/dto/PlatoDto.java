package ar.edu.ubp.das.dto;

public class PlatoDto {
  private String nroPlato;
  private String nomPlato;

  public PlatoDto() {
  }

  public PlatoDto(String nroPlato, String nomPlato) {
    this.nroPlato = nroPlato;
    this.nomPlato = nomPlato;
  }

  public String getNroPlato() {
    return nroPlato;
  }

  public void setNroPlato(String nroPlato) {
    this.nroPlato = nroPlato;
  }

  public String getNomPlato() {
    return nomPlato;
  }

  public void setNomPlato(String nomPlato) {
    this.nomPlato = nomPlato;
  }
}
