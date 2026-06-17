/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Assignment type in your schema. */
class Assignment extends amplify_core.Model {
  static const classType = const _AssignmentModelType();
  final String id;
  final String? _yearMonth;
  final String? _date;
  final String? _memberId;
  final String? _memberName;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  AssignmentModelIdentifier get modelIdentifier {
      return AssignmentModelIdentifier(
        id: id
      );
  }
  
  String get yearMonth {
    try {
      return _yearMonth!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get date {
    try {
      return _date!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get memberId {
    try {
      return _memberId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get memberName {
    try {
      return _memberName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Assignment._internal({required this.id, required yearMonth, required date, required memberId, required memberName, createdAt, updatedAt}): _yearMonth = yearMonth, _date = date, _memberId = memberId, _memberName = memberName, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Assignment({String? id, required String yearMonth, required String date, required String memberId, required String memberName}) {
    return Assignment._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      yearMonth: yearMonth,
      date: date,
      memberId: memberId,
      memberName: memberName);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Assignment &&
      id == other.id &&
      _yearMonth == other._yearMonth &&
      _date == other._date &&
      _memberId == other._memberId &&
      _memberName == other._memberName;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Assignment {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("yearMonth=" + "$_yearMonth" + ", ");
    buffer.write("date=" + "$_date" + ", ");
    buffer.write("memberId=" + "$_memberId" + ", ");
    buffer.write("memberName=" + "$_memberName" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Assignment copyWith({String? yearMonth, String? date, String? memberId, String? memberName}) {
    return Assignment._internal(
      id: id,
      yearMonth: yearMonth ?? this.yearMonth,
      date: date ?? this.date,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName);
  }
  
  Assignment copyWithModelFieldValues({
    ModelFieldValue<String>? yearMonth,
    ModelFieldValue<String>? date,
    ModelFieldValue<String>? memberId,
    ModelFieldValue<String>? memberName
  }) {
    return Assignment._internal(
      id: id,
      yearMonth: yearMonth == null ? this.yearMonth : yearMonth.value,
      date: date == null ? this.date : date.value,
      memberId: memberId == null ? this.memberId : memberId.value,
      memberName: memberName == null ? this.memberName : memberName.value
    );
  }
  
  Assignment.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _yearMonth = json['yearMonth'],
      _date = json['date'],
      _memberId = json['memberId'],
      _memberName = json['memberName'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'yearMonth': _yearMonth, 'date': _date, 'memberId': _memberId, 'memberName': _memberName, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'yearMonth': _yearMonth,
    'date': _date,
    'memberId': _memberId,
    'memberName': _memberName,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<AssignmentModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<AssignmentModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final YEARMONTH = amplify_core.QueryField(fieldName: "yearMonth");
  static final DATE = amplify_core.QueryField(fieldName: "date");
  static final MEMBERID = amplify_core.QueryField(fieldName: "memberId");
  static final MEMBERNAME = amplify_core.QueryField(fieldName: "memberName");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Assignment";
    modelSchemaDefinition.pluralName = "Assignments";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        provider: amplify_core.AuthRuleProvider.APIKEY,
        operations: const [
          amplify_core.ModelOperation.READ
        ]),
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Assignment.YEARMONTH,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Assignment.DATE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Assignment.MEMBERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Assignment.MEMBERNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _AssignmentModelType extends amplify_core.ModelType<Assignment> {
  const _AssignmentModelType();
  
  @override
  Assignment fromJson(Map<String, dynamic> jsonData) {
    return Assignment.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Assignment';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Assignment] in your schema.
 */
class AssignmentModelIdentifier implements amplify_core.ModelIdentifier<Assignment> {
  final String id;

  /** Create an instance of AssignmentModelIdentifier using [id] the primary key. */
  const AssignmentModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'AssignmentModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is AssignmentModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}