import React from "react"
import PropTypes from "prop-types"
class SectionDetailModal extends React.Component {
  render () {
    return (
      <div>
        <div>hello Id: {this.props.id}</div>
      </div>
    );
  }
}

SectionDetailModal.propTypes = {
  id: PropTypes.node
};
export default SectionDetailModal
