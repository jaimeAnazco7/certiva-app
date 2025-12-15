/// Configuración de Supabase
/// 
/// IMPORTANTE: Reemplaza estos valores con tus credenciales de Supabase
/// Puedes encontrarlas en: https://app.supabase.com/project/_/settings/api
class SupabaseConfig {
  // URL de tu proyecto Supabase
  // Ejemplo: 'https://xxxxx.supabase.co'
  static const String supabaseUrl = 'https://sgsfmxbofvzbgiqqovxw.supabase.co';
  
  // Clave anónima (anon/public key) de tu proyecto Supabase
  // Esta es la clave pública, segura para usar en el cliente
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnc2ZteGJvZnZ6YmdpcXFvdnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2MTY2MDcsImV4cCI6MjA3OTE5MjYwN30.4X_MgaDwn0kJO3AOypUd2laKckJv6-mL01JPgHRwFio';
  
  // URL de redirección para OAuth (debe coincidir con la configurada en Supabase)
  // Para Android: 'io.supabase.certiva://login-callback/'
  // Para iOS: 'io.supabase.certiva://login-callback/'
  static const String redirectUrl = 'io.supabase.certiva://login-callback/';
}

