<?php
/**
 *
 * SugarCRM Community Edition is a customer relationship management program developed by
 * SugarCRM, Inc. Copyright (C) 2004-2013 SugarCRM Inc.
 *
 * SuiteCRM is an extension to SugarCRM Community Edition developed by SalesAgility Ltd.
 * Copyright (C) 2011 - 2022 SalesAgility Ltd.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License version 3 as published by the
 * Free Software Foundation with the addition of the following permission added
 * to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK
 * IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY
 * OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along with
 * this program; if not, see http://www.gnu.org/licenses or write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301 USA.
 *
 * You can contact SugarCRM, Inc. headquarters at 10050 North Wolfe Road,
 * SW2-130, Cupertino, CA 95014, USA. or at email address contact@sugarcrm.com.
 *
 * The interactive user interfaces in modified source and object code versions
 * of this program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU Affero General Public License version 3.
 *
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3,
 * these Appropriate Legal Notices must retain the display of the "Powered by
 * SugarCRM" logo and "Supercharged by SuiteCRM" logo. If the display of the logos is not
 * reasonably feasible for technical reasons, the Appropriate Legal Notices must
 * display the words "Powered by SugarCRM" and "Supercharged by SuiteCRM".
 */
if (!defined('sugarEntry') || !sugarEntry) {
    die('Not A Valid Entry Point');
}

#[\AllowDynamicProperties]
class OutboundEmailAccountsController extends SugarController
{
    public function action_EditView() {
        $this->view = 'edit';
        $type = $_REQUEST['type'] ?? '';
        if (!empty($this->bean) && $type !== '') {
            $this->bean->type = $type;
        }

        if (empty($this->bean) && $type === 'system' && !is_admin($GLOBALS['current_user'])) {
            $this->hasAccess = false;
            $this->view = 'noaccess';
            return;
        }

        $oe = new OutboundEmail();
        $oe = $oe->getSystemEmail();
        if (empty($this->bean->id) && $type === 'system' && $oe !== null) {
            $this->hasAccess = false;
            $this->view = 'errors';
            $this->errors = [
                translate('LBL_ERROR_OUTBOUND_EMAIL_SYSTEM_EXISTS', 'OutboundEmailAccounts'),
            ];
            return;
        }

        if ($type === 'system' && $oe !== null && $oe->id !== $this->bean->id) {
            $this->hasAccess = false;
            $this->view = 'errors';
            $this->errors = [
                translate('LBL_ERROR_OUTBOUND_EMAIL_SYSTEM_EXISTS', 'OutboundEmailAccounts'),
            ];
            return;
        }

        if (empty($_REQUEST['record']) && $type === 'user') {
            $this->hasAccess = true;
            return;
        }

        if (!empty($this->bean) && $type === 'user' && $this->bean->hasAccessToPersonalAccount()) {
            $this->hasAccess = true;
        }
    }

    public function action_save() {
        global $current_user, $mod_strings;
        $isNewRecord = (empty($this->bean->id) || $this->bean->new_with_id);

        $this->bean->mail_sendtype = 'SMTP';

        if (!empty($_REQUEST['user_id']) && is_admin($current_user)) {
            $this->bean->assigned_user_id = $_REQUEST['user_id'];
            $this->bean->user_id = $_REQUEST['user_id'];
        }

        if ($isNewRecord && !empty($_REQUEST['user_id']) && !is_admin($current_user)) {
             $_REQUEST['user_id'] = '';
             $this->bean->user_id = '';
        }

        if (!$isNewRecord && !empty($_REQUEST['user_id']) && !is_admin($current_user)) {
             $_REQUEST['user_id'] = '';
             if (!empty($this->bean->fetched_row['user_id'])) {
                 $this->bean->user_id = $this->bean->fetched_row['user_id'];
             }
        }

        $oe = new OutboundEmail();
        $oe = $oe->getSystemEmail();
        $type = $this->bean->type;

        if ($type === 'user'){
            $type = 'personal';
        }

        if ($isNewRecord && empty($this->bean->user_id)) {
            $this->bean->user_id = $current_user->id;
            $this->bean->assigned_user_id = $current_user->id;
        }

        if (!$isNewRecord && !empty($this->bean->user_id) && empty($this->bean->assigned_user_id)) {
            $this->bean->assigned_user_id = $this->bean->user_id;
        }

        $authType = $_REQUEST['auth_type'] ?? '';

        $oauth = null;
        if ($authType === 'oauth' || ($_REQUEST['auth_type'] ?? '') === 'oauth') {
            $oauth = BeanFactory::getBean('ExternalOAuthConnection', $_REQUEST['external_oauth_connection_id']);
        }

        if ($type === 'system' && $oe !== null && $oe->id !== $this->bean->id) {
            $this->hasAccess = false;
            $this->view = 'errors';
            $this->errors = [
                translate('LBL_ERROR_OUTBOUND_EMAIL_SYSTEM_EXISTS', 'OutboundEmailAccounts'),
            ];
            return;
        }

        if ($type === 'system' && $oauth !== null && $oauth->type !== 'group') {
            SugarApplication::appendErrorMessage($mod_strings['LBL_ERROR_OUTBOUND_EMAIL_SYSTEM_IS_NOT_GROUP']);
            SugarApplication::redirect('index.php?module=OutboundEmailAccounts&action=DetailView&record=' . $this->bean->id);
            return;
        }

        if ($type !== 'system' && $oauth !== null && $oauth->type !== $type) {
            SugarApplication::appendErrorMessage($mod_strings['LBL_ERROR_OUTBOUND_EMAIL_CONNECTION_TYPE_MISMATCH']);
            SugarApplication::redirect('index.php?module=OutboundEmailAccounts&action=DetailView&record=' . $this->bean->id);
            return;
        }

        parent::action_save();
    }

    public function action_SetDefault()
    {
        global $current_user;
        $outbound_id = empty($_REQUEST['record']) ? "" : $_REQUEST['record'];
        $oe = BeanFactory::newBean('OutboundEmailAccounts');

        $ownerId = $this->bean->created_by ?? '';
        if (empty($ownerId)) {
            $ownerId = $current_user->id;
        }

        $owner = BeanFactory::getBean('Users', $ownerId);

        if($ownerId === $current_user->id || is_admin($current_user)){
            $oe->setUsersDefaultOutboundAccount($owner, $outbound_id);
        }

        $module = (!empty($this->return_module) ? $this->return_module : $this->module);
        $action = (!empty($this->return_action) ? $this->return_action : 'DetailView');
        $id = (!empty($this->return_id) ? $this->return_id : $outbound_id);

        $url = "index.php?module=" . $module . "&action=" . $action . "&record=" . $id;
        $this->set_redirect($url);
    }
}
