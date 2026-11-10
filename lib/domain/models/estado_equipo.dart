class EstadoEquipo {
  const EstadoEquipo({
    this.bloqueado = false,
    this.motivo,
    this.verificado = true,
  });

  const EstadoEquipo.noVerificado()
    : bloqueado = false,
      motivo = null,
      verificado = false;

  final bool bloqueado;
  final String? motivo;
  final bool verificado;
}
