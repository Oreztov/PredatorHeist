core:import("CoreMissionScriptElement")

ExpandedModifyPlayerElement = ExpandedModifyPlayerElement or class(CoreMissionScriptElement.MissionScriptElement)

function ExpandedModifyPlayerElement:init(...)
	ExpandedModifyPlayerElement.super.init(self, ...)
end

function ExpandedModifyPlayerElement:client_on_executed(...)
	self:on_executed(...)
end

function ExpandedModifyPlayerElement:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local is_player = instigator == managers.player:player_unit()
	if not is_player then return end

	local movement = instigator:movement()
	local current_state = movement:current_state()

	if self._values.disable_running then
		managers.player:set_player_rule("no_run", true)

		if current_state._interupt_action_running then
			current_state:_interupt_action_running(managers.player:player_timer():time())
		end
	else
		managers.player:set_player_rule("no_run", false)
	end

	if self._values.speed_multiplier then
		managers.player.pre_modified_movement_speed_multiplier = managers.player.pre_modified_movement_speed_multiplier or managers.player.movement_speed_multiplier
		managers.player.movement_speed_multiplier = function(...)
			return self._values.speed_multiplier * managers.player.pre_modified_movement_speed_multiplier(...)
		end
	end

	self.super.on_executed(self, instigator)
end

-- Editor stuff because the module integration seems to be broken.
if BLE then
	Hooks:Add("BeardLibPostInit", "ExpandedModifyPlayerElementEditor", function(self)
		ExpandedModifyPlayerEditor = ExpandedModifyPlayerEditor or class(MissionScriptEditor)

		function ExpandedModifyPlayerEditor:create_element()
		    self.super.create_element(self)

		    self._element.class = "ExpandedModifyPlayerElement"

		    self._element.values.speed_multiplier = 1.0
		    self._element.values.disable_running = false 
		end

		function ExpandedModifyPlayerEditor:_build_panel()
			self:_create_panel()

		    self:NumberCtrl("speed_multiplier", {floats = 1, min = 0, help = "Player movement speed multiplier"})
		    self:BooleanCtrl("disable_running", {help = "Disable Running"})
		end

		table.insert(BLE._config.MissionElements, "ExpandedModifyPlayerElement")
	end)
end