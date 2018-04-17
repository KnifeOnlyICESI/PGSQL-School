/***********************************************************************************************************************
 *
 * This file contains script for create triggers of school database
 *
 * Author : Dany Pignoux
 *
***********************************************************************************************************************/

DROP TRIGGER IF EXISTS trigger_update_average ON score;

CREATE TRIGGER trigger_update_average AFTER INSERT OR UPDATE ON score FOR EACH ROW
EXECUTE PROCEDURE update_average();