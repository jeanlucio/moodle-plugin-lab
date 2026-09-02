<?php
// This file is part of Moodle - https://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <https://www.gnu.org/licenses/>.

/**
 * Installs a Moodle language pack from the CLI (Moodle 5.x removed the built-in
 * admin/cli/install_language_pack.php script). Used once by the devcontainer setup.
 *
 * @package    core
 * @copyright  2026 Moodle Plugin Lab
 * @license    https://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

define('CLI_SCRIPT', true);

require(__DIR__ . '/../moodle/config.php');
require_once($CFG->libdir . '/clilib.php');
require_once($CFG->libdir . '/adminlib.php');

$lang = $argv[1] ?? 'pt_br';

// A moodle_exception is thrown on download failure, so a normal return here
// means the pack is installed (or already up to date).
$controller = new \tool_langimport\controller();
$controller->install_languagepacks($lang);

cli_writeln("Language pack '{$lang}' is installed.");
