# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2022 Nautech Systems Pty Ltd. All rights reserved. https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from nautilus_trader.common.actor cimport Actor
from nautilus_trader.execution.algorithm cimport ExecAlgorithmSpecification
from nautilus_trader.execution.matching_core cimport MatchingCore
from nautilus_trader.execution.messages cimport CancelAllOrders
from nautilus_trader.execution.messages cimport CancelOrder
from nautilus_trader.execution.messages cimport ModifyOrder
from nautilus_trader.execution.messages cimport SubmitOrder
from nautilus_trader.execution.messages cimport SubmitOrderList
from nautilus_trader.execution.messages cimport TradingCommand
from nautilus_trader.model.c_enums.liquidity_side cimport LiquiditySide
from nautilus_trader.model.events.order cimport OrderCanceled
from nautilus_trader.model.events.order cimport OrderEvent
from nautilus_trader.model.events.order cimport OrderExpired
from nautilus_trader.model.events.order cimport OrderFilled
from nautilus_trader.model.events.order cimport OrderRejected
from nautilus_trader.model.events.order cimport OrderTriggered
from nautilus_trader.model.events.order cimport OrderUpdated
from nautilus_trader.model.identifiers cimport ClientId
from nautilus_trader.model.identifiers cimport ClientOrderId
from nautilus_trader.model.identifiers cimport PositionId
from nautilus_trader.model.orders.base cimport Order
from nautilus_trader.model.orders.limit cimport LimitOrder
from nautilus_trader.model.orders.market cimport MarketOrder


cdef class OrderEmulator(Actor):
    cdef dict _matching_cores
    cdef dict _commands_submit_order
    cdef dict _commands_submit_order_list

    cdef set _subscribed_quotes
    cdef set _subscribed_trades
    cdef set _subscribed_strategies
    cdef set _monitored_positions

    cpdef void execute(self, TradingCommand command) except *
    cdef void _handle_submit_order(self, SubmitOrder command) except *
    cdef void _handle_submit_order_list(self, SubmitOrderList command) except *
    cdef void _handle_modify_order(self, ModifyOrder command) except *
    cdef void _handle_cancel_order(self, CancelOrder command) except *
    cdef void _handle_cancel_all_orders(self, CancelAllOrders command) except *

    cdef void _create_new_submit_order(self, Order order, PositionId position_id, ExecAlgorithmSpecification exec_algorithm_spec, ClientId client_id) except *
    cdef void _cancel_order(self, MatchingCore matching_core, Order order) except *

# -- EVENT HANDLERS -------------------------------------------------------------------------------

    cpdef void _handle_order_rejected(self, OrderRejected rejected) except *
    cpdef void _handle_order_canceled(self, OrderCanceled canceled) except *
    cpdef void _handle_order_expired(self, OrderExpired expired) except *
    cpdef void _handle_order_updated(self, OrderUpdated updated) except *
    cpdef void _handle_order_filled(self, OrderFilled filled) except *
    cpdef void _check_contingencies_on_order_close(self, Order order) except *

# -------------------------------------------------------------------------------------------------

    cpdef void _trigger_stop_order(self, Order order) except *
    cpdef void _fill_market_order(self, Order order, LiquiditySide liquidity_side) except *
    cpdef void _fill_limit_order(self, Order order, LiquiditySide liquidity_side) except *

    cdef void _iterate_orders(self, MatchingCore matching_core) except *
    cdef void _update_trailing_stop_order(self, MatchingCore matching_core, Order order) except *
    cdef MarketOrder _transform_to_market_order(self, Order order)
    cdef LimitOrder _transform_to_limit_order(self, Order order)
    cdef void _hydrate_initial_events(self, Order original, Order transformed) except *

# -- EGRESS ---------------------------------------------------------------------------------------

    cdef void _send_risk_command(self, TradingCommand command) except *
    cdef void _send_exec_command(self, TradingCommand command) except *
    cdef void _send_risk_event(self, OrderEvent event) except*
    cdef void _send_exec_event(self, OrderEvent event) except *
