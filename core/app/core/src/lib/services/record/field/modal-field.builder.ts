/**
 * SuiteCRM is a customer relationship management program developed by SuiteCRM Ltd.
 * Copyright (C) 2025 SuiteCRM Ltd.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License version 3 as published by the
 * Free Software Foundation with the addition of the following permission added
 * to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK
 * IN WHICH THE COPYRIGHT IS OWNED BY SUITECRM, SUITECRM DISCLAIMS THE
 * WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * In accordance with Section 7(b) of the GNU Affero General Public License
 * version 3, these Appropriate Legal Notices must retain the display of the
 * "Supercharged by SuiteCRM" logo. If the display of the logos is not reasonably
 * feasible for technical reasons, the Appropriate Legal Notices must display
 * the words "Supercharged by SuiteCRM".
 */

import {Injectable} from "@angular/core";
import {FieldBuilder} from "./field.builder";
import {ValidationManager} from "../validation/validation.manager";
import {DataTypeFormatter} from "../../formatters/data-type.formatter.service";
import {FieldObjectRegistry} from "./field-object-type.registry";
import {ViewFieldDefinition} from "../../../common/metadata/metadata.model";
import {LanguageStore} from "../../../store/language/language.store";
import {Field, FieldDefinition} from "../../../common/record/field.model";

@Injectable({
    providedIn: 'root'
})
export class ModalFieldBuilder extends FieldBuilder {

    constructor(
        protected validationManager: ValidationManager,
        protected typeFormatter: DataTypeFormatter,
        protected fieldRegistry: FieldObjectRegistry
    ) {
        super(validationManager, typeFormatter, fieldRegistry);
    }


    /**
     * Build filter field
     *
     * @param module
     * @param {object} viewField ViewFieldDefinition
     * @param {object} language LanguageStore
     * @returns {object} Field
     */
    public buildModalField(module: string, viewField: ViewFieldDefinition, language: LanguageStore = null): Field {

        const definition = (viewField && viewField.fieldDefinition) || {} as FieldDefinition;

        const field = this.setupField(
            module,
            viewField,
            null,
            null,
            null,
            null,
            definition,
            null,
            null,
            language
        );

        return field;
    }
}
