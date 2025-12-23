## Titulo
Preguntas y respuestas 

## Pasos
Hacer pregunta en pantalla de preguntas
Responder pregunta
Notificaciones al vendedor cuando hay nueva pregunta o respuesta
Notificaciones al comprador cuando hay respuesta a su pregunta

## Restricciones
- Solo usuarios autenticados pueden hacer preguntas o respuestas
- Las preguntas y respuestas son privadas, es decir, no son visibles para otros usuarios

## Requisitos Tecnicos
- Respetar la arquitectura de carpetas
- Guardar preguntas y respuestas en Firestore
- Usar Cloud Functions para enviar notificaciones

## Implementación
- Firestore:
	- Preguntas en `vehicles/{vehicleId}/questions/{questionId}` con campos `buyerUserId`, `sellerUserId`, `text`, `createdAt`, `participants`, `answerCount`.
	- Respuestas en `vehicles/{vehicleId}/questions/{questionId}/answers/{answerId}` con `responderUserId`, `text`, `createdAt`.
- Privacidad: Las consultas filtran por `participants` (`arrayContains` el `uid` actual) para que solo comprador y vendedor vean su hilo.
- Autenticación: Solo usuarios autenticados pueden crear preguntas y respuestas.
- Notificaciones (Cloud Functions):
	- Trigger `onQuestionCreate` crea una notificación para el vendedor.
	- Trigger `onAnswerCreate` crea una notificación para el comprador o vendedor (quien no respondió).
	- Se guardan en `notifications` con `userId`, `type`, `vehicleId`, `questionId`, `message`, `createdAt`, `read`, `fromUserId`.

## Archivos creados
- `lib/data/models/question_model.dart`
- `lib/data/models/answer_model.dart`
- `lib/data/services/qa_service.dart`
- `lib/providers/qa_provider.dart`
- `lib/presentation/screens/qa/qa_screen.dart`
- `firebase/functions/index.js` y `firebase/functions/package.json`

## Uso rápido
- Mostrar la pantalla de preguntas: instanciar `QAScreen(vehicleId: '<id>', sellerUserId: '<uidVendedor>')` (integrada en `vehicle_detail_screen.dart`).
- Crear pregunta: campo de texto + botón "Preguntar" en `QAScreen`.
- Responder: campo de texto por hilo en `QAScreen`.
- Providers disponibles:
  - `questionsForVehicleProvider(vehicleId)`: Stream de preguntas filtradas por participantes.
  - `answersForQuestionProvider((vehicleId: vehicleId, questionId: questionId))`: Stream de respuestas.
  - `askQuestionProvider`: FutureProvider para crear pregunta.
  - `answerQuestionProvider`: FutureProvider para responder.

## Desarrollo local
- Emuladores Firebase: usar los ya configurados en el proyecto.
- Functions: dentro de `firebase/functions`, instalar dependencias y arrancar emuladores.
  
	```bash
	cd firebase/functions
	npm install
	# En la raíz del proyecto, arrancar emuladores si no están activos
	firebase emulators:start --only functions,firestore
	```

## Estado de Implementación ✅
- [x] Modelos de datos (QuestionModel, AnswerModel)
- [x] Servicio QA (QAService) con autenticación y privacidad
- [x] Providers Riverpod para preguntas/respuestas
- [x] Pantalla QAScreen con UI para preguntar y responder
- [x] Triggers Cloud Functions para notificaciones
- [x] Integración en vehicle_detail_screen.dart con botón "Preguntas"
- [x] Documentación completa y ejemplos de uso

## Flujo de usuario
1. Usuario ve detalle de vehículo en `vehicle_detail_screen.dart`
2. Presiona botón "Preguntas" → navega a `QAScreen`
3. En `QAScreen`: puede hacer pregunta (si es comprador) o responder (si es vendedor)
4. Preguntas/respuestas se guardan en Firestore con privacidad garantizada
5. Cloud Functions crean notificaciones en collection `notifications`


